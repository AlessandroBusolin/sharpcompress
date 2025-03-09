TECT.TXT   ��<  U�R��<  using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace SharpCompress
{
    internal static class Utility
    {
        public static ReadOnlyCollection<T> ToReadOnly<T>(this IEnumerable<T> items)
        {
            return new ReadOnlyCollection<T>(items.ToList());
        }

        /// <summary>
        /// Performs an unsigned bitwise right shift with the specified number
        /// </summary>
        /// <param name="number">Number to operate on</param>
        /// <param name="bits">Ammount of bits to shift</param>
        /// <returns>The resulting number from the shift operation</returns>
        public static int URShift(int number, int bits)
        {
            if (number >= 0)
                return number >> bits;
            else
                return (number >> bits) + (2 << ~bits);
        }

        /// <summary>
        /// Performs an unsigned bitwise right shift with the specified number
        /// </summary>
        /// <param name="number">Number to operate on</param>
        /// <param name="bits">Ammount of bits to shift</param>
        /// <returns>The resulting number from the shift operation</returns>
        public static int URShift(int number, long bits)
        {
            return URShift(number, (int)bits);
        }

        /// <summary>
        /// Performs an unsigned bitwise right shift with the specified number
        /// </summary>
        /// <param name="number">Number to operate on</param>
        /// <param name="bits">Ammount of bits to shift</param>
        /// <returns>The resulting number from the shift operation</returns>
        public static long URShift(long number, int bits)
        {
            if (number >= 0)
                return number >> bits;
            else
                return (number >> bits) + (2L << ~bits);
        }

        /// <summary>
        /// Performs an unsigned bitwise right shift with the specified number
        /// </summary>
        /// <param name="number">Number to operate on</param>
        /// <param name="bits">Ammount of bits to shift</param>
        /// <returns>The resulting number from the shift operation</returns>
        public static long URShift(long number, long bits)
        {
            return URShift(number, (int)bits);
        }

        /// <summary>
        /// Fills the array with an specific value from an specific index to an specific index.
        /// </summary>
        /// <param name="array">The array to be filled.</param>
        /// <param name="fromindex">The first index to be filled.</param>
        /// <param name="toindex">The last index to be filled.</param>
        /// <param name="val">The value to fill the array with.</param>
        public static void Fill<T>(T[] array, int fromindex, int toindex, T val) where T : struct
        {
            if (array.Length == 0)
            {
                throw new NullReferenceException();
            }
            if (fromindex > toindex)
            {
                throw new ArgumentException();
            }
            if ((fromindex < 0) || ((System.Array)array).Length < toindex)
            {
                throw new IndexOutOfRangeException();
            }
            for (int index = (fromindex > 0) ? fromindex-- : fromindex; index < toindex; index++)
            {
                array[index] = val;
            }
        }

        /// <summary>
        /// Fills the array with an specific value.
        /// </summary>
        /// <param name="array">The array to be filled.</param>
        /// <param name="val">The value to fill the array with.</param>
        public static void Fill<T>(T[] array, T val) where T : struct
        {
            Fill(array, 0, array.Length, val);
        }

        /// <summary> Read a int value from the byte array at the given position (Big Endian)
        /// 
        /// </summary>
        /// <param name="array">the array to read from
        /// </param>
        /// <param name="pos">the offset
        /// </param>
        /// <returns> the value
        /// </returns>
        public static int readIntBigEndian(byte[] array, int pos)
        {
            int temp = 0;
            temp |= array[pos] & 0xff;
            temp <<= 8;
            temp |= array[pos + 1] & 0xff;
            temp <<= 8;
            temp |= array[pos + 2] & 0xff;
            temp <<= 8;
            temp |= array[pos + 3] & 0xff;
            return temp;
        }

        /// <summary> Read a short value from the byte array at the given position (little
        /// Endian)
        /// 
        /// </summary>
        /// <param name="array">the array to read from
        /// </param>
        /// <param name="pos">the offset
        /// </param>
        /// <returns> the value
        /// </returns>
        public static short readShortLittleEndian(byte[] array, int pos)
        {
            return BitConverter.ToInt16(array, pos);
        }

        /// <summary> Read an int value from the byte array at the given position (little
        /// Endian)
        /// 
        /// </summary>
        /// <param name="array">the array to read from
        /// </param>
        /// <param name="pos">the offset
        /// </param>
        /// <returns> the value
        /// </returns>
        public static int readIntLittleEndian(byte[] array, int pos)
        {
            return BitConverter.ToInt32(array, pos);
        }

        /// <summary> Write an int value into the byte array at the given position (Big endian)
        /// 
        /// </summary>
        /// <param name="array">the array
        /// </param>
        /// <param name="pos">the offset
        /// </param>
        /// <param name="value">the value to write
        /// </param>
        public static void writeIntBigEndian(byte[] array, int pos, int value)
        {
            array[pos] = (byte)((Utility.URShift(value, 24)) & 0xff);
            array[pos + 1] = (byte)((Utility.URShift(value, 16)) & 0xff);
            array[pos + 2] = (byte)((Utility.URShift(value, 8)) & 0xff);
            array[pos + 3] = (byte)((value) & 0xff);
        }

        /// <summary> Write a short value into the byte array at the given position (little
        /// endian)
        /// 
        /// </summary>
        /// <param name="array">the array
        /// </param>
        /// <param name="pos">the offset
        /// </param>
        /// <param name="value">the value to write
        /// </param>
#if SILVERLIGHT || MONO || PORTABLE
        public static void WriteLittleEndian(byte[] array, int pos, short value)
        {
            byte[] newBytes = BitConverter.GetBytes(value);
            Array.Copy(newBytes, 0, array, pos, newBytes.Length);
        }
#else
        unsafe public static void WriteLittleEndian(byte[] array, int pos, short value)
        {
            fixed (byte* numRef = &(array[pos]))
            {
                *((short*)numRef) = value;
            }
        }
#endif

        /// <summary> Increment a short value at the specified position by the specified amount
        /// (little endian).
        /// </summary>
        public static void incShortLittleEndian(byte[] array, int pos, short incrementValue)
        {
            short existingValue = BitConverter.ToInt16(array, pos);
            existingValue += incrementValue;
            WriteLittleEndian(array, pos, existingValue);
            //int c = Utility.URShift(((array[pos] & 0xff) + (dv & 0xff)), 8);
            //array[pos] = (byte)(array[pos] + (dv & 0xff));
            //if ((c > 0) || ((dv & 0xff00) != 0))
            //{
            //    array[pos + 1] = (byte)(array[pos + 1] + ((Utility.URShift(dv, 8)) & 0xff) + c);
            //}
        }

        /// <summary> Write an int value into the byte array at the given position (little
        /// endian)
        /// 
        /// </summary>
        /// <param name="array">the array
        /// </param>
        /// <param name="pos">the offset
        /// </param>
        /// <param name="value">the value to write
        /// </param>
#if SILVERLIGHT || MONO || PORTABLE
        public static void WriteLittleEndian(byte[] array, int pos, int value)
        {
            byte[] newBytes = BitConverter.GetBytes(value);
            Array.Copy(newBytes, 0, array, pos, newBytes.Length);
        }
#else
        unsafe public static void WriteLittleEndian(byte[] array, int pos, int value)
        {
            fixed (byte* numRef = &(array[pos]))
            {
                *((int*)numRef) = value;
            }
        }
#endif
        public static void MemSet(this List<byte> mem, int offset, int length)
        {
            if (mem.Count < offset + length)
            {
                for (int i = 0; i < offset + length; ++i)
                {
                    mem.Add((byte)0);
                }
            }
        }


        public static void AddRange<T>(this ICollection<T> destination, IEnumerable<T> source)
        {
            foreach (T item in source)
            {
                destination.Add(item);
            }
        }

        public static void ForEach<T>(this IEnumerable<T> items, Action<T> action)
        {
            foreach (T item in items)
            {
                action(item);
            }
        }

        public static IEnumerable<T> AsEnumerable<T>(this T item)
        {
            yield return item;
        }

        public static void CheckNotNull(this object obj, string name)
        {
            if (obj == null)
            {
                throw new ArgumentNullException(name);
            }
        }

        public static void CheckNotNullOrEmpty(this string obj, string name)
        {
            obj.CheckNotNull(name);
            if (obj.Length == 0)
            {
                throw new ArgumentException("String is empty.");
            }
        }

        public static void Skip(this Stream source, long advanceAmount)
        {
            byte[] buffer = new byte[32 * 1024];
            int read = 0;
            int readCount = 0;
            do
            {
                readCount = buffer.Length;
                if (readCount > advanceAmount)
                {
                    readCount = (int)advanceAmount;
                }
                read = source.Read(buffer, 0, readCount);
                if (read < 0)
                {
                    break;
                }
                advanceAmount -= read;
                if (advanceAmount == 0)
                {
                    break;
                }
            } while (true);
        }

        public static void SkipAll(this Stream source)
        {
            byte[] buffer = new byte[32 * 1024];
            do
            {
            } while (source.Read(buffer, 0, buffer.Length) == buffer.Length);
        }


        public static byte[] UInt32ToBigEndianBytes(uint x)
        {
            return new byte[] { 
                (byte)((x >> 24) & 0xff), 
                (byte)((x >> 16) & 0xff), 
                (byte)((x >> 8) & 0xff), 
                (byte)(x & 0xff) };
        }

        public static DateTime DosDateToDateTime(UInt16 iDate, UInt16 iTime)
        {
            int year = iDate / 512 + 1980;
            int month = iDate % 512 / 32;
            int day = iDate % 512 % 32;
            int hour = iTime / 2048;
            int minute = iTime % 2048 / 32;
            int second = iTime % 2048 % 32 * 2;

            if (iDate == UInt16.MaxValue || month == 0 || day == 0)
            {
                year = 1980;
                month = 1;
                day = 1;
            }

            if (iTime == UInt16.MaxValue)
            {
                hour = minute = second = 0;
            }

            DateTime dt;
            try
            {
                dt = new DateTime(year, month, day, hour, minute, second);
            }
            catch
            {
                dt = new DateTime();
            }
            return dt;
        }

        public static uint DateTimeToDosTime(this DateTime? dateTime)
        {
            if (dateTime == null)
            {
                return 0;
            }
            return (uint)(
                (dateTime.Value.Second / 2) | (dateTime.Value.Minute << 5) | (dateTime.Value.Hour << 11) |
                (dateTime.Value.Day << 16) | (dateTime.Value.Month << 21) | ((dateTime.Value.Year - 1980) << 25));
        }


        public static DateTime DosDateToDateTime(UInt32 iTime)
        {
            return DosDateToDateTime((UInt16)(iTime / 65536),
                                     (UInt16)(iTime % 65536));
        }

        public static DateTime DosDateToDateTime(Int32 iTime)
        {
            return DosDateToDateTime((UInt32)iTime);
        }

        public static long TransferTo(this Stream source, Stream destination)
        {
            byte[] array = new byte[4096];
            int count;
            long total = 0;
            while ((count = source.Read(array, 0, array.Length)) != 0)
            {
                total += count;
                destination.Write(array, 0, count);
            }
            return total;
        }

        public static bool ReadFully(this Stream stream, byte[] buffer)
        {
            int total = 0;
            int read;
            while ((read = stream.Read(buffer, total, buffer.Length - total)) >= 0)
            {
                total += read;
                if (total >= buffer.Length)
                {
                    return true;
                }
            }
            return (total >= buffer.Length);
        }

        public static string TrimNulls(this string source)
        {
            return source.Replace('\0', ' ').Trim();
        }

#if PORTABLE
        public static void CopyTo(this byte[] array, byte[] destination, int index)
        {
            Array.Copy(array, 0, destination, index, array.Length);
        }

        public static long HostToNetworkOrder(long host)
        {
            return (int)((long)HostToNetworkOrder((int)host)
                & unchecked((long)(unchecked((ulong)-1))) << 32
                | ((long)HostToNetworkOrder((int)((int)host >> 32)) & unchecked((long)(unchecked((ulong)-1)))));
        }
        public static int HostToNetworkOrder(int host)
        {
            return (int)((int)(HostToNetworkOrder((short)host) & -1) << 16 | (HostToNetworkOrder((short)(host >> 16)) & -1));
        }
        public static short HostToNetworkOrder(short host)
        {
            return (short)((int)(host & 255) << 8 | ((int)host >> 8 & 255));
        }
        public static long NetworkToHostOrder(long network)
        {
            return HostToNetworkOrder(network);
        }
        public static int NetworkToHostOrder(int network)
        {
            return HostToNetworkOrder(network);
        }
        public static short NetworkToHostOrder(short network)
        {
            return HostToNetworkOrder(network);
        }
#endif
    }
}
TEST.EXE   � �  wX��y� �  MZ�       ��  �       @                                   �   � �	�!�L�!This program cannot be run in DOS mode.
$       	�kM�}8M�}8M�}8Τs8A�}8��w8g�}8�n8D�}8M�|8�}8��v8_�}8RichM�}8        PE  L ^�<        �   p   �      	1      �    @                                                             �  d                                                                                    �  h                          .text   f      p                    `.rdata  d   �       �              @  @.data   ([   �      �              @  �                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        �D$����SUVW�  �|$(�0�@ �G����:�u��t�P�^��:�u������u�3�������-�@ ����   jj j �Ջ؅�u
h�@ �  hĪ@ h�  ���@ � �@ ���3����+�P���ѿĪ@ �����O���PPPPhĪ@ Pj��jh   ��h�@ h�@ S��(�@ ��u
hȠ@ �   h��@ �x�@ �%  hp#@ j
����  ���i  �|$(�G���@ ����:�u��t�P�^��:�u������u�3��������u}jPP�Յ�uh�@ �!h   h�@ P��@ P� �@ ��u,h��@ �x�@ �  hp#@ j
���B  ����  _^][���h\�@ �x�@ �k  hp#@ j
���  ���  �G�T�@ ����:�u��t�P�^��:�u������u�3��������uEP�D$(WP�z  ����u2�~  _^][��ÍL$3�Q�D$�@ �D$P@ �D$�D$ ��@ _^][��Ð��������QV3�h�@ h�@ �@�@ 0   �D�@    �H�@    �5L�@ �5P�@ �5T�@ �5X�@ �$�@ ;ƣ��@ ��   �L$�T$�D$PQR��   ��;�t;���@ �L�@ �D$h@�@ Q�D�@    �5T�@ �5X�@ �P�@ ��@ ^Y� ���@ W�=�@ h@�@ R�5L�@ �D�@    �5T�@ �5X�@ ���]  ���@ h@�@ P�5L�@ �D�@    �5T�@ �5X�@ ��_^Y� ��������������Ð����������������  ��$�  SU�- �@ 3�V��W�D$�  vu��$�  �T�@ �q���:u:�t�V��:Wu����:�u�3������;�u9�9���3����+������Ī@ ����3����Ī@ ������I�щT$�H�L$QjSh�@ h  ��ՋD$�T$RhĪ@ SShԡ@ P��@ �L$I�L$�L$Q��@ �T$�С@ ���3�����@ ���+��t$�����|$����3����Ī@ �������@ ���+��D$0�ы��x�@ P����h  ����P�@ ��t"����h��@ �������   _^][�İ  ÍL$QjSh�@ h  ��ՋD$�T$RhP�@ SSh��@ P�D$(   ��@ �5�@ ��t9�L$QjSh�@ h  ��ՋT$jhP�@ jSh��@ R�֋D$�=�@ P����=�@ �D$3ɍT$�L$ RhĪ@ �L$,SS�L$8h��@ P�L$D�D$(�  ��@ ��tv�L$�T$ QhĪ@ SjRf�D$4 f�D$6 Q�D$8�\$9�\$:�D$;�D$$�  �T�@ �D$PjSh�@ h  ��ՋL$�T$QhĪ@ jSh��@ R�֋D$P��� �L$�T$ QRSjhĪ@ �D$$   �L�@ �T$3��L$� �@ QhĪ@ �$�@ SS�(�@ h��@ R�,�@ �D$(�  ��@ ����   �D$f� �@  PhĪ@ Sjh �@ f�"�@  P�$�@ �%�@ �&�@ �'�@ �D$$�  �T�@ �L$QjSh�@ h  ��ՋT$�D$RhĪ@ jSh��@ P�֋L$Q��� �T$�D$   Rh �@ SjhĪ@ �L�@ �T$3��L$�0�@ QhĪ@ �4�@ SS�8�@ h��@ R�<�@ �D$(�  ��@ ����   �D$f�0�@  PhĪ@ Sjh0�@ f�2�@  P�4�@ �5�@ �6�@ �7�@ �D$$�  �T�@ �L$QjSh�@ h  ��ՋT$�D$RhĪ@ jSh��@ P�֋L$Q��� �T$�D$   Rh0�@ SjhĪ@ �L�@ �D$P��jjj�\�@ ������@ u"�C���ht�@ �9������   _^][�İ  ÍL$ jQP�`�@ ��t"����hh�@ �������   _^][�İ  Ë��@ h���R�X�@ ��t"�����hX�@ ��������   _^][�İ  �h`�@ �L�@ ����h<�@ ������3�_^][�İ  ËD$V�5�@ HuD���@ Wh@�@ P�D�@    �֡d�@ �=T�@ ���`�@    t	���@ Q�׋x�@ R��_���@ h@�@ P��^� �������������QUh`�@ �@�@ �d�@ 3����   SVW���@ �D$��@ �C��~S���tM�P�@ �s���=h�@ F���;�~���K�j P�C�PQ�H�@ ���t��~�+ȉ�{��э4���ʃ��C��t�;�a  }�D$�Q�T�@ �; u!�C��~�C��}�C��u�S�jR�@�@ �T$�d�@ E����0;�T$�H���_^[h`�@ �P�@ ]Y� ����������� Sh`�@ �@�@ �d�@ 3ۅ���  UVW���@ ���@ ���@ �|$,�t$$�D$��@ �l$(�D$��@ �D$��@ �D$Ĳ@ �D$�8 �  �L$�9 ��   �D$�8 ��   �M Q�e  �d�@ 3���;ȉD$ ~8���@ ;�t�T$�;Q�u�T$ B�T$ �J��d�@ @��0;�|ՋD$ ��u�h�@ �P�T�@ j2�D�@ �Q�H�@ �d�@ J;ډT$ }-��+Ӎo0�   �����J�H���u�T$ �|$,�t$$�l$(�L$�0   +�K�L$�L$+ȃ��L$�L$+�+�L$�L$+ȉd�@ �L$+���0   �L$Cȃ��L$�L$��L$�L$���L$�L$�;ډt$$�l$(�L$�|$,�����_^]h`�@ �P�@ [�� Ð����4Sh�  �  �D$�`�@ 3ۃ�;��
  UVWu�d�@ ;�ujd�D�@ �`�@ ;�t�d�@ ;���  j�Sh��@ Q�0�@ ���ujd�D�@ h`�@ �@�@ �d�@ ;É\$��  ���@ ���@ 9^|�N��D$PSQ�8�@ ��t�   3��|$�D$�t_9\$,u%9^| �T$�=<�@ �F   �F�SSRP�׋D$�:�M �V�SQR�4�@ �F�P�D�@ �^�F�����N�jQ�@�@ ��   �=<�@ � t�F�����F   ��t�>�a  |�F   �   ;�u	9^��   �=�a  ��   ��a  S+�R�V��P�F�P�׃��t;�~9^~�^�N;�}[9^} ���t;�~��N��V�Sh�a  QR��9^|�9^}1���t;�u(�E �N�SPQ�4�@ �V�R�D�@ �x�@ �^P�T�@ �D$�d�@ @����0;��D$�����h`�@ �P�@ �`�@ ;������_^]�L$Q��  ��3�[��4� ������������V��V�T$����^� �����������������LSh�@ �������3�SSSS�4�@ j)�x�@ P���@ P�4�@ ���u+h̢@ �������,�@ P����hȢ@ ������[��L�SSSh @ SS�8�@ j�D$��@ jShP@ Sh�  ��@ �D$�`�@ ;���  UVW�x�@ j�Q�<�@ ���ujd�D�@ h`�@ �@�@ �d�@ �\$;��,  ���@ 9]|�E؍T$0RSP�8�@ ��t�   3��|$0�D$0� tc�M؋5<�@ Sh�  hĪ@ Q�փ��t;�~�U�Sh�  hĪ@ R�փ��u�E�P�D�@ �E�����E ;���   �M�jQ�@�@ �]��|�tx9] ~s9]�un�U�Sh�  hĪ@ R�<�@ �؃��tP��~L3�;�})�U���+�j ��Ī@ PQR�H�@ ��j2��D�@ ���uӋE�j h�  hĪ@ P�<�@ �؃��u�3ۋD$�d�@ @��0;��D$�����h`�@ �P�@ ���@ �L$0QSR�8�@ �D$0�-  �=d�@ �   �  ����h��@ �������@ ���D$�L$ P�   QR�t$ �0�@ �d�@ �I���������@ u�P���h��@ �  ǁĲ@    �7���9t$u-�d�@ �L$ �T$$�@����@ ��L$(�P�T$,�H�P�+h��@ ������d�@ ��3ɍ@����@ �
�J�J�Jjjj�\�@ �d�@ �I���������@ u/����hp�@ �����d�@ ���@������@ P�D�@ �  Vh0�@ P�`�@ SSSS�4�@ �d�@ j1P����@ �I������@ R�4�@ ���u�C���hh�@ �9������d�@ Vh �@ �@������@ Q�(�@ �d�@ h�a  �@������@ ��  �d�@ ��3��R��;Ӊ���@ ����@ ����@ ~���@ ���h�;���@ u�(FE�(��0Ou�;󉱬�@ u�h�@ ���@ BP�d�@ �T�@ �����h,�@ �������\���9`�@ �5���_^]�L$Q��@ j� �@ �x�@ ���@ SRP�4�@ ���@ Q�T�@ h�   �D�@ �T$R�H�@ ����h�@ ������[��LÐ������������L$��  ��������   �   ������j���@ �L  Ð��h�#@ �  YÐ������@ ��  ���@ �6  ������������U��V���   ��tf�W�@ƃx0 t�E�e �E
�E
Phh�@ ���  �4�}�HW�6   ���u"�W�@�L0��P���u��@�L0�D0���S   _��^]� �A;A s�T$��A���	��t$�P� ��@��H��t	���H3�Ë@ ��t���   jX�V���@�d00 ��@��@% t�@�ȋ�R���u��@�D0   ��@�D0%@t<hأ@ �N  ���Yu��@�L0�D0h��@ �0  ���Yu��@�L0�D0^�V���O�����t�t$��hh�@ �p  ���]�����^� V���@�L0��P���u��@�L0�D0��^�V�q�W�~���   ���|  �D$tV�
  Y��_^� ��u@ �_  QQ�e� �} V��u�t�N�t�@ ��  �E�   �e� ��u�@�0p�@ ��H��@  �M�f ��^d�    �� �A��@�D�p�@ �V�q�W�~���z   ����  �D$tV�
  Y��_^� ��u@ ��  QQ�e� �} V��u�t�N���@ �P  �E�   �e� j ���u� �����M�@�0��@ ��^d�    �� �A��@�D���@ �U���U��QQSVW���u�k  �u���a  �؋Y�]��@Y�;�0�D00;�v	+�+ǉE���e� �A$
uB�E��M���~8�E��X��@��H,Q�H�<������u��@�L0�D0K�M���wы]���t$�W�u�@�L0��P;�t��@�L0�D0��@�D0$t=�}���O���}�~0G��@��H,Q�H��������u��@�L0�D0O�M���wыS�u�@�L0��P;�t��@�L0�D0��@�D0$t7�E���H��~-�x��@��H,Q�H�\������u��@�L0�D0Ou֋�_^[�� �   �E   ��u@ ��  Qj8�"  Y�ȉM�3�;ȉE�tj�G  �M��jP�x�@ ������M�d�    ��hj(@ �`  Y�V���@ ���������|  ^��   �#   �x�@ ����t
�x�@ �@�j�P�p�@ �   �h�(@ �  Yùp�@ �$   �T$�|$ ���B   |�B x�@ ~�J% � ø�u@ �
  QQSVW3�9]��j�u�]�_t�N���@ �   �}��]�j8�)  Y�ȉM;ˉ}�t�  �3�SP�Έ]��M�����M�@�0��@ ��@�|0��_^[d�    �� V�q�W�~���   ���v   �D$tV�  Y��_^� �A��@�D���@ �L�����3�� ��@ �H�@   �H�H�H �H$�@(   �@, �H0�H�V���   �D$tV�O  Y��^� V��~ ���@ t�N��t�j��f �F   ^�V��~ t�N��t�j��D$���Ft�f���N^� V���/  �f4 �N0��́@ ��^�V���3   �D$tV��  Y��^� V����  �D$�f4 �F0�́@ ��^� �v@ �K  QV��u��́@ �e� �~4 t�   ��  �M������  �M�^d�    ��V��W�~0�t"��P�v0���  ���Yt���t�N0����3�_^�VW���  ���;�t]���>  ;�tR�N��u�F�F�F�F�F 9|$t��u�F;F s�t$�������jX_^� �D$jP�v0��  ����t����U��QVW���   ��t�F(� �s���  ���;�tM���   ;�tB�~ t�E�jP�v0�'  ����~'�E��9�F�N;�v+��3�PQ�v0�   ��������N�~��N$�N(�F,�_^�ËQ(�A,;�s+��3�ËD$S3�V+Ë�tHtHu(j�j[���"   ���tS�t$�v0�  �����u���^[� SV����W�N0;���   3�9^��   �~�F;�r+��3�;�t/WPQ�  ��;�t ;�~y9^ t)F�v+��WPV�r  ���]�Ή^�^�^ �;���;�~P�~0�ϋ������� �@ �\��Àt�N(�V,;�s	�9
u@A����t@��jPW��  �����u����3ۃN��^$�^(�^,3�_^[�V��~0�t
�~ t3��(�D$��t�L$��~�j QP����  ��F   ��^� ��3ɃH�� ��@ �H�H�H�H�H�H�H �H$�H(�H,�V���   �D$tV�w  Y��^� V�����@ �7  �~ t�v��tV�O  Y^Ë��x u'�L$��t�T$��t�Hʃ` �H��@   �3�� U��Q�e� S�]V��K��W��t5�}�~ u�F;F s	���F���Q���P���tG�E���K��u΋E�_^[�� U��Q�e� SV��W�~ tE�~�u��P �F�]��K��t#�}�~�t�F�Έ�G�E��P �F��K��u��E�_^[�� �]��t����P ���t�F(�~,+�;�|����~�WP�u�y  }~(}���+��ċA(;A,r�A;Aw3�Ã��Ãy u�y u��P(@�����H�3��V��h   ��   ��Yu���^Í�   jQP���   jX^�V��~ t�F��tP�   Y�D$�F�D$�F�D$�F^� ���� �t$�j �t$�P� V��F$;F(s�t$�H   �B�jjj����P���u��,�~ S�\$u�F,��t�N(+�HPQAQ�2  �F(�����[^� �A(9A$sH�A(�L$�����T$�R�P$� �t$�j  Y�j�t$�  YY�V�5��@ �  ���@ Y���@ ��+��;�^s:R��  ��P�5��@ ��  ����uË��@ +��@ ���@ �������@ �D$����@ ��t$�������Y��H�h�   �   ��Y���@ uj��   ���@ Y�  ���@ ���@ �U��j�h(�@ h�N@ d�    Pd�%    ��SVW�e��X�@ 3Ҋԉ��@ �ȁ��   ���@ ��ʉ��@ �����@ j ��  Y��uj�   Y�e� �  ���@ �$�@ �  ���@ �I  �  ��  ���@ ���@ P�5��@ �5��@ �C������E�P��  �E��	�M�PQ��  YYËe��u���  �=��@ t�  �t$�  h�   ���@ YYÃ=��@ t�a  �t$�  Yh�   ���@ �V�t$��u	V�   Y^�V�#   ��Yt���^��F@t�v�  ��Y^��3�^�SV�t$3�W�F�ȃ���u7f�t1�F�>+���~&WP�v�  ��;�u�F��t$��F��N ����F�f �_��^[�j�   Y�SVW3�3�3�95 �@ ~M��@ ����t8�H���t0�|$uP�.������YtC��|$ u��tP�������Yu�F;5 �@ |��|$��t��_^[á �@ Vj��^u�   �;�}�ƣ �@ jP��  Y��@ ��Yu!jV�5 �@ ��  Y��@ ��Yuj�X���Y3ɸ��@ ��@ ��� ��=8�@ |�3ҹȣ@ �������� �@ �����t��u�	��� B��(�@ |�^�������=�@  t��  ��8�@ �I��tQ�  Y�V��������D$tV�!���Y��^� U��QSVW�E���E�d�    �d�    �E�]�c��m���_^[�� XY�$��XY�$��U��QQSVWd�    �E��E��4@ j �u�u��u��@  �E�@$��M�Ad�    �]��d�    _^[�� U���SVW��E�3�PPP�u��u�u�u�u��  �� �E_^[�E��]�U����E�e� �M�E�E�E�C5@ @�M��E�d�    �E썅����d�    �uQ�u�%  �ȋE�d�    ����U����Ej P�p�pj �u�p�u�a  �� ]�U���4SVW�e� �E�6@ �E�E��E�E�E�E�E �E�e� �e� �e� �e� �E��5@ �e�m�d�    �E؍�����d�    �E�   �E�EЋE�EԍE�P�E�0�,�@ YY�e� �}� td�    ��]؉d�    �	�E�d�    �E�_^[��U��SVW��E�@��f��t�E�@$   jX�Mj�E�p�E�p�E�pj �u�E�p�u�^  �� �E�x$ u�u�u������]�c�k �cjX_^[]�U��QSV�} W�}�w�_�Ɖu�E�|9���u�$  �MN��9L���};H~���u�E�M�E��u�} }ʋE��MF�1�M�;Gw;�v�a$  ��_^��[��U��SVWUj j h$7@ �u�P>  ]_^[��]ËL$�A   �   t�D$�T$��   �SVW�D$Pj�h,7@ d�5    d�%    �D$ �X�p���t.;t$$t(�4v���L$�H�|� uh  �D��@   �T���d�    ��_^[�3�d�    �y,7@ u�Q�R9Qu�   �SQ�P�@ �
SQ�P�@ �M�K�C�kY[� ��j�Pd�    P�D$d�%    �l$�l$P�����̋L$��   t�A��t@��   u�    �����~Ѓ��3�� �t�A���t2��t$�  � t�   �t�͍A��L$+�ÍA��L$+�ÍA��L$+�ÍA��L$+��SUVW�|$;= �@ ��   �ǋ������� �@ ����D0tiW��#  ���Yt<��t��uj�#  j���#  Y;�YtW�#  YP�H�@ ��u
���@ ���3�W�#  �Y�d0 ��t	U�"  Y�3���%��@  ���@ 	   ���_^][�U���  �MS; �@ VW�y  ���������� �@ ����D0��W  3�9}�}��}�u3��W  � tjWQ�E  �����@���   �E9}�E��}��   �������M�+M;Ms)�M��E��	��
u�E�� @�@�ȍ�����+ʁ�   |̋�������+��E�j P������WP��40���@ ��tC�E�E�;�|�E�+E;Er�3��E�;���   9}t_jX9EuL���@ 	   ���@ �   ���@ �E�ǍM�WQ�u�u�0���@ ��t�E�}�E�����@ �E��u�!  Y�=��D0@t�E�8��������@    �=��@ �+E���%��@  ���@ 	   ���_^[��U���SV�uW;5 �@ ��  �ƃ������� �@ �� �@ ƊP����  �e� �}�} ��tg��ub��Ht�@<
t�M���O�E�   �D0
�E�j P��uQ�40���@ ��u:���@ jY;�u���@ 	   ���@ �>  ��mu3��5  P��  Y�&  ��U�U��L0�D0����   ��t	�?
u�$���E�M��E�;��M���   �E� <��   <t�G�E�   I9Ms�E@�8
u�E�^�G�E�s�E�j P�E�E�jP��40���@ ��u
���@ ��uG�}� tA��D0Ht�E�<
t��G�D1�);}u�}�
u�
�jj��u�O   ���}�
t�G�M�9M�G������t0��@u�+}�}��E���%��@  ���@ 	   ���_^[�ËD$S; �@ VWss�ȋ������<� �@ ����D1tVP�v  ���Yu���@ 	   �O�t$j �t$P�Ā@ �؃��u���@ �3���t	P�W  Y� ��d0��D0����%��@  ���@ 	   ���_^[Ã�DSUVWh   �H  ��Y��uj�>���Y�5 �@ � �@     ��   ;�s�f ���F
� �@ ��   ��D$P�Ԁ@ f�|$B ��   �D$D����   �0�h�   ;��.|��95 �@ }R��@ h   �  ��Yt8� �@  ���   ;�s�` ���@
�����   ���95 �@ |���5 �@ 3���~F����t6�M ��t.��uP�Ѐ@ ��t�ǋ������� �@ �ȋ��M �HGE��;�|�3ۡ �@ �<���4�uM���F�uj�X�
��H������P�̀@ �����tW�Ѐ@ ��t%�   �>��u�N@���u
�N��N�C��|��5 �@ �Ȁ@ _^][��D�����������U��WV�u�M�}�����;�v;��x  ��   u������r)��$��@@ �Ǻ   ��r����$��?@ �$��@@ ��$�@@ ��?@ �?@  @@ #ъ��F�G�F���G������r���$��@@ �I #ъ��F���G������r���$��@@ �#ъ�F��G��r���$��@@ �I @@ l@@ d@@ \@@ T@@ L@@ D@@ <@@ �D��D��D��D��D��D��D���D���D��D��D���D���D���D����    ���$��@@ ���@@ �@@ �@@ �@@ �E^_�Ð���E^_�Ð���F�G�E^_�ÍI ���F�G�F�G�E^_�Ð�t1��|9���   u$������r����$� B@ �����$��A@ �I �Ǻ   ��r��+��$�(A@ �$� B@ �8A@ XA@ �A@ �F#шGN��O��r�����$� B@ �I �F#шG�F���G������r�����$� B@ ��F#шG�F�G�F���G�������Z�������$� B@ �I �A@ �A@ �A@ �A@ �A@ �A@ B@ B@ �D��D��D��D��D��D��D��D��D��D��D��D��D��D���    ���$� B@ ��0B@ 8B@ HB@ \B@ �E^_�Ð�F�G�E^_�ÍI �F�G�F�G�E^_�Ð�F�G�F�G�F�G�E^_��j�l���Y���U��WV�u�M�}�����;�v;��x  ��   u������r)��$��C@ �Ǻ   ��r����$��B@ �$��C@ ��$�\C@ ��B@ C@ @C@ #ъ��F�G�F���G������r���$��C@ �I #ъ��F���G������r���$��C@ �#ъ�F��G��r���$��C@ �I �C@ �C@ �C@ �C@ �C@ �C@ �C@ |C@ �D��D��D��D��D��D��D���D���D��D��D���D���D���D����    ���$��C@ ���C@ �C@ �C@  D@ �E^_�Ð���E^_�Ð���F�G�E^_�ÍI ���F�G�F�G�E^_�Ð�t1��|9���   u$������r����$�`E@ �����$�E@ �I �Ǻ   ��r��+��$�hD@ �$�`E@ �xD@ �D@ �D@ �F#шGN��O��r�����$�`E@ �I �F#шG�F���G������r�����$�`E@ ��F#шG�F�G�F���G�������Z�������$�`E@ �I E@ E@ $E@ ,E@ 4E@ <E@ DE@ WE@ �D��D��D��D��D��D��D��D��D��D��D��D��D��D���    ���$�`E@ ��pE@ xE@ �E@ �E@ �E^_�Ð�F�G�E^_�ÍI �F�G�F�G�E^_�Ð�F�G�F�G�F�G�E^_��V�t$��t$V�P  Y��Vt
P�o  YY^�j �5��@ �\�@ ^��58�@ �t$�   YYÃ|$�w"�t$�   ��Yu9D$t�t$��!  ��Yu�3��V�t$;5�@ wV�5  ��Yu��uj^�����Vj �5��@ �`�@ ^�S�\$UV��Wu�t$�w���Y�   �t$��uS�4���Y3���   3������   S�z  ��Y����   ;5�@ wDVSU�j  ����t���)V�  ��Y��t$�C�H;�r��PSW����SU�Y  ������   ��uj^�����Vj �5��@ �`�@ ����tA�C�H;�r��PSW�[���SU�  �����uj^�����VSj �5��@ ���@ ����u�=8�@  tV�   ��Y����������_^][á��@ ��t��h(�@ h�@ ��   h�@ h �@ �   ���j j �t$�   ���j j�t$�   ���Wj_9=�@ u�t$��@ P��@ �|$ S�\$�=�@ ��@ u<���@ ��t"���@ V�q�;�r���t�Ѓ�;5��@ s�^h4�@ h,�@ �*   YYh@�@ h8�@ �   YY��[u�t$�=�@ ���@ _�V�t$;t$s���t�Ѓ���^�V�t$V�  ��Yt�F�^��	�Vj �5��@ ��@ ^�U��S�u�5  ��Y�   �X���  ��u�` jX�  ����   ��@ �M�M��@ �H����   ��@ ��@ �V;�}�4I+э4�x�@ �& ��Ju�� �5��@ =�  �u���@ �   �p=�  �u���@ �   �]=�  �u���@ �   �J=�  �u���@ �   �7=�  �u���@ �   �$=�  �u���@ �   �=�  �u
���@ �   �5��@ j��Y�5��@ Y^��` Q��Y�E��@ ����	�u���@ []ËT$��@ 9p�@ V�p�@ t�4I�4�p�@ ��;�s9u��I^��p�@ ;�s9t3��S3�9��@ VWu�"  �5��@ 3��:�t<=tGV�����Y�t���   P�~�����Y;�5��@ uj	�n���Y�=��@ 8t9UW������YE�?=t"U�I���;�Y�uj	�?���YW�6�~  Y��Y�8u�]�5��@ �����Y���@ �_^���@    [�U��QQS3�9��@ VWu��!  ��@ h  VS��@ �$�@ �5 �@ ��8t���E�P�E�PSSW�M   �E��M���P��������;�uj����Y�E�P�E�P�E���PVW�   �E���H�5��@ _^���@ [��U��M�ESV�! �uW�}�    �E��t�7���}�8"uD�P@��"t)��t%������@ t���t��F@���tՊ�F�����t�& F�8"uF@�C���t��F�@������@ t���t��F@�� t	��t	��	ū�uH���t�f� �e �8 ��   ��� t��	u@��8 ��   ��t�7���}�U��E   3ۀ8\u@C���8"u,��u%3�9}t�x"�Pu����}�}3�9U�U���K��tC��t�\F�Ku���tJ�} u
�� t?��	t:�} t.��t������@ t�F@���F�������@ t@��@�X�����t�& F�������t�' �E_^[� ]�QQ��@ SU�-�@ VW3�3�3�;�u3�Ջ�;�t��@    �(� �@ ��;���   ��@    �   ����   ;�u�Ջ�;���   f9��t@@f9u�@@f9u�+Ƌ=��@ ��SS@SSPVSS�D$4�׋�;�t2U����;�Y�D$t#SSUP�t$$VSS�ׅ�u�t$�����Y�\$�\$V���@ ���S��uL;�u� �@ ��;�t<8��t
@8u�@8u�+�@��U������Y;�u3��UWV�8�����W�܀@ ���3�_^][YY�3�j 9D$h   ��P��@ �����@ t�R  ��u�5��@ ��@ 3��jX��VC20XC00U���SVWU��]�E�@   ��   �E��E�E��E��C��s�{���ta�v�|� tEVU�k�T�]^�]�t3x<�{S�	������kVS�>������vj�D���������C�T��{�v�4�롸    ��   �U�kj�S�������]�   ]_^[��]�U�L$�)�AP�AP�������]� ���@ ��t��u*�=��@ u!h�   �   � �@ Y��t��h�   �   Y�U���  �U3ɸ �@ ;t��A=��@ |�V����;� �@ �  ���@ ����   ��u�=��@ ��   ���   ��   ��\���h  Pj ��@ ��u��\���h�@ P��  YY��\���WP��\��������@Y��<v)��\���P��������\�����;j�h�@ W�  ����`���h�@ P�  ��`���WP�  ��`���h��@ P�  ���@ ��`���P�}  h  ��`���hȄ@ P�'  ��,_�&�E���@ j P�6�.���YP�6j��̀@ P���@ ^�ËD$; �@ s=�ȋ������� �@ �D�t%P�g  YP���@ ��u���@ �3���t���@ ���@ 	   ����SV�t$W�t$�����w��uj^�����3����w*;�@ wS��  ��Y��u+Vj�5��@ �`�@ ����u"�=8�@  tV�V  ��Yt�Sj W��  ����_^[�3���VWj3�^95 �@ ~D��@ ����t/�@�tP��  ���YtG��|��@ �4�������@ Y�$� F;5 �@ |���_^������������̋T$�L$��   u<�:u.
�t&:au%
�t��:Au
�t:au����
�uҋ�3�Ð���@Ë���   t�B:u�A
�t���   t�f���:u�
�t�:au�
�t����U��V�uW� �9>t�  �E�@ft�~ to�} uij�V�u�u�  ���V�~ tP�8csm�u,9xv'�H�I��t�U$R�u �uV�u�u�uP�у� ��u �u�u$V�u�u�uP�
   �� jX_^]�U����E�e� �@����E�|�M;A|��  SV�u�csm�W� �9�?  �~uV9~uQ�~ uK�5$�@ ���  �(�@ jV�E�E���  Y��Yu�  9��   �~u9~u�~ u�j  9��   �~��   9~��   �}��E�P�E�PW�u �u�g������؋E�;E���   9;|;{w�C�E�C���E�~d�F�@�x� ���E�~�v�7�u�;  ����u�M���9E���M�E�}� ��$�u��u$�u S�7�u�u�u�u�uV�
  ��,�}��E����i����} t
jV�`  YY_^[�À} u �u$�u �u��u�u�u�uV�
   �� ���  U��QQ�=,�@  VWt!�u$�u �u�u�u�u�u�8�������us�}�E�P�E�PW�u �u�C��������E�;E�sO;>|C;~>�F�N����H��t�y u&j����u$�u Vj P�u�u�u�u�u�   ��,�E����_^��VW�|$�G��tJ�x �PtA�t$�N;�t��QR�g���Y��Yu"�t�t�D$� �t�t	�t	�u3��jX_^�U��j�h0�@ h�N@ d�    Pd�%    ��SVW�e�]�s�u�};utU���~;w|�  �e� �G�D���th  SP�T  �M����u��/   YËe�M���}�]�u�G�4��u�릉s�M�d�    _^[�ËD$� �8csm�t3���M  U��}  S�]VW�}t�u SW�u�  ���}, �uuW��u,�u����u$�6�u�uW�����Fh   �u(@�G�s�u�uW�u�   ��,��tWP�����_^[]�U��j�h@�@ h�N@ d�    Pd�%    ��SVW�e�E�E�3ۉ]܋u�N��M؋$�@ �M�(�@ �M��}�=$�@ �M�(�@ �]��E�   �u �uP�uV�=������Eԉ]��M���<   �EԋM�d�    _^[���u��h   YËe�e� j��E�P�\���YY3���3ۋu�}�E؉F��E�$�@ �E�(�@ �?csm�u'�u!� �u9]�u9]�t�z���PW��  YYËD$� �8csm�u�xu�x �u
�x ujX�3��U��j�hX�@ h�N@ d�    Pd�%    ��SVW�e�M�A���u  �x �k  �A���`  �U�|�e� �tD�uj�v��  YY���0  jW��  YY���  �F��M��QP�  YY��  �u�tR�]j�s�  YY����   jW�  YY����   �v�sW��������~��   �����   ��V뗃~ �]j�su:�(  YY����   jW�2  YY��t~�v��V�s��   YYPW�������f��  YY��tVjW��  YY��tH�v�
  Y��t;�tj�FP�s�   YYP�vW�o�����FP�s�   YYP�vW�N�����M  �M���M�d�    _^[��jXËe���   U��j�hh�@ h�N@ d�    Pd�%    QQSVW�e�E��t�H�I��t�e� Q�p������M���M�d�    _^[��3�8E��Ëe��q   �L$V�t$��Qƅ�|�42�I���^���U���SQ�E���E��EU�u�M�m������VW��_^��]�MU���   u�   Q�����]Y[�� U��j�hx�@ h�N@ d�    Pd�%    QQSVW�e�e� �0�@ ��t�E�   ���jXËe�e� �M���    �  U��j�h��@ h�N@ d�    Pd�%    QQSVW�e�e� ���@ ��t�E�   ���jXËe�e� �M���    �T����L$3҉��@ ���@ ;t ��B=�@ |��r��$w���@    Ëլ�@ ���@ Á��   r���   ���@    v
���@    ËL$V; �@ WsU���������<� �@ �����@t7�8�t2�=��@ u3�+�tItIuPj��Pj��Pj����@ ��0�3���%��@  ���@ 	   ���_^ËD$; �@ s�ȃ����� �@ �D���t� Ã%��@  ���@ 	   ����h@  j �5��@ �`�@ �����@ uÃ%��@  �%��@  j���@ ���@    Xá��@ �����@ ��;�s�T$+P��   r����3��U����U�MSV�A��+q�Z����W���΋z�i�  K�}���D  �]�M�����M�u��j?I_�M;�v�}�L;LuH�M�� s�   ���L��!|�D�	u+�M!9�$���   ���M�L��!���   �	u�M!y�L�|�y�L�|]��y�]����O��?vj?_�M����M���   +U��M���j?�U�IZ;ʉMv�U��]����]���O;�v��;�tk�M��Q;QuH�M�� s�   ���L��!T�D�	u+�M!�$���   ���M�L��!���   �	u�M!Q�M��Q�I�J�M��Q�I�J�U��}� u	9}��   �M����I�J�M����J�Q�J�Q�J;Juc�L�� �M���Ls%�} u�   �����M	�   �����D�D	�)�} u�O�   ���M	Y�O�   ����   	8�]�E���\����   ���@ ����   ���@ �=؀@ ��H� �  h @  SQ�׋��@ ���@ �   ���	P���@ ���@ �@����    ���@ �@�HC���@ �H�yC u	�`����@ �x�ulSj �p�ס��@ �pj �5��@ �\�@ ���@ ���@ �����ȡ��@ +ȍL�Q�HQP�����E�����@ ;��@ v�����@ ���@ ��E���@ �5��@ _^[��U������@ ���@ SV��W�<��E�}��H����M���I�� }�����M���u��������3���u�E����@ ��;߉]s�K�;#M�#��u��;]��]r�;]�uy��;؉]s�K�;#M�#��u����;�uY;]�s�{ u���]��;]�u&��;؉]s�{ u����;�u�8  �؅ۉ]tS��  Y�K��C�8�u3��  ���@ �C�����U�t����   �|�D#M�#��u7���   �pD#U�#u�e� �HD֋u�u���   �E�#U�����#9�t�U���3�i�  ��D  �M�L�D#�u����   j #M�_��|��G���M�T��
+M���M���N��?~j?^;��  �J;Jua�� }+�   �����M��|8�Ӊ]�#\�D�\�D�u8�]�M�!�1�O�   ���M��|8����   ��!��]�u�]�M�!K��]�J�z�}� �y�J�z�y��   �M�|���z�J�Q�J�Q�J;Jud�L�� �M})���} �Lu�   �����	;�   �����M�	|�D�/���} �Lu�N�   ���	{�M�����   �N�   ���	7�M���t�
�L���M��u�эN�
�L2��u��ɍy�>u;��@ u�M�;��@ u�%��@  �M���B_^[�á��@ ���@ VW3�;�u0�D�P��P�5��@ W�5��@ ���@ ;�ta���@ ���@ ���@ ���@ h�A  j���5��@ �4��`�@ ;ǉFt*jh    h   W���@ ;ǉFu�vW�5��@ �\�@ 3���N��>�~���@ �F����_^�U��Q�MSVW�q�A3ۅ�|��C����j?i�  Z��0D  �E��@�@��Ju��j��yh   h �  W���@ ��u����   �� p  ;�w<�G�H�����  ����  �@��  ��������Hǀ�  �     �H�;�vǋE��O�  j_�H�A�J�H�A�d�D ����   �FC�������E�NCu	x�   �������!P��_^[��U����M�ESVW�}�׍p+Q�A�������i�  ��D  �M�O�I;�M�\9��|9��]��_  ���O  �;��E  �M���I��?�M�vj?Y�M��_;_uH�� s�   ���M��L��!\�D�	u+�M!�$���   ���M��L��!���   �	u�M!Y�O�_�Y�O��y�M+�M��}� ��   �}��M��O�L1���?vj?_�]���]�[�Y�]�Y�K�Y�K�Y;Yu\�L�� �M���Ls!�} u�   �����M	�D�D�   ����%�} u�O�   ���M	Y����   �O�   ���	�U�M��D2���L���U�F�B��D2��G  3��C  �:  �])u�N�K��\3��u�]��N�K���?vj?^�E���   �u���N��?vj?^�O;OuG�� s�   �����t��!\�D�u(�M!�!�N�   ���L��!���   �	u�M!Y�]�O�w�q�O�w�q�uu��u��N��?vj?^�M�|���{�K�Y�K�Y�K;Ku\�L�� �M���Ls!�} u�   �����M	9�D�D�   ����%�} u�N�   ���M	y����   �N�   ���	�E��D�jX_^[�á<�@ ��t�t$�Ѕ�YtjX�3��W�|$�j��$    ���L$W��   t�A��t;��   u�����~Ѓ��3�� �t�A���t#��t�  � t�   �t�͍y���y���y���y��L$��   t�A��td�G��   u���������~�Ѓ��3��� �t��t4��t'��  � t��   �t�ǉ�D$_�f��D$�G _�f��D$_È�D$_�U���SVW�u�  ��Y;5��@ �u�j  3�;��V  3Ҹ(�@ 90tr��0B=�@ |�E�PV���@ ���$  j@3�Y���@ �}��5��@ 󫪉��@ ��   �}� ��   �M�����   �A���;���   ����@ @��j@3�Y���@ �4R�]������8�@ �; ��t,�Q��t%���;�w�U��� �@ ���@ @;�v�AA�9 u��E����}�r��E���@    P���@ ��   ��,�@ ���@ ��Y���@ ��UAA�y� �H���jX����@ @=�   r�V�   Y���@ ���@    ����@ 3����@ ����9@�@ t�   �   3�����_^[�ËD$�%@�@  ���u�@�@    �%��@ ���u�@�@    �%��@ ���u�l�@ �@�@    ËD$-�  t"��t��tHt3�ø  ø  ø  ø  �Wj@Y3����@ �3����@ ���@ ���@ ���@ ���_�U���  �E�VP�5��@ ���@ ���  3��   ������@;�r�E�ƅ���� ��t7SW�U��
��;�w+ȍ�����A�    �����˃��BB�B���u�_[j �������5��@ �5��@ P������VPj�  j �������5��@ VP������VPV�5��@ �  j �������5��@ VP������VPh   �5��@ ��  ��\3�������f���t����@ ����������@ ���t����@  �������〠��@  @AA;�r��I3��   ��Ar��Zw����@ �Ȁ� ����@ ���ar��zw����@  �Ȁ� ������@  @;�r�^�Ã=��@  uj��,���Y���@    �S3�9D�@ VWuBh؅@ ���@ ��;�tg�5��@ h̅@ W�օ��D�@ tPh��@ W��h��@ W�H�@ �֣L�@ �H�@ ��t�Ћ؅�t�L�@ ��tS�Ћ��t$�t$�t$S�D�@ _^[�3���������̋L$W��tzVS�ًt$��   �|$u��uo�!�F�GIt%��t)��   u����uQ��t�F�G��t/Ku�D$[^_���   t�GI��   ��   u����ul�GKu�[^�D$_É��It�����~�Ѓ��3��� �tބ�t,��t��  � t��   �uƉ�����  �����   ��3҉��3�It
3����Iu���u��D$[^_��̋T$�L$��tG3��D$W����r-�ك�t+шGIu������������ʃ���t��t�GJu��D$_ËD$�V�t$W����F�@t����:��t4V�e���V����  �v��������}�����F��tP�����f Y�ǃf _^�V�t$��8csm�u�xu�x �u�����P�@ ��tP�j   ��Yt	V�P�@ �3�^� h>o@ �|�@ �P�@ ��5P�@ �|�@ �Vj^�t$�t$�x�@ ��t3���^�Vj^�t$�t$���@ ��t3���^�Vj^�t$���@ ��t3���^�j
����j�  YYj�����������Q=   �L$r��   -   �=   s�+ȋą���@P�U��j�h��@ h�N@ d�    Pd�%    ��SVW�e�3�9=t�@ uFWWj[Sh�@ �   VW�t�@ ��t�t�@ �"WWSh�@ VW�l�@ ���"  �t�@    9}~�u�u�  YY�E�t�@ ��u�u�u�u�u�u�u�l�@ ��   ����   9} u�l�@ �E WW�u�u�E$�����@P�u �p�@ �؉]�;���   �}����$�������e�ĉE܃M���jXËe�3��}܃M���]�9}�tfS�u��u�uj�u �p�@ ��tMWWS�u��u�u�t�@ ���u�;�t2�Et@9}��   ;u�u�uS�u��u�u�t�@ ����   3��eȋM�d�    _^[���E�   �6��$������e�܉]��M���jXËe�3�3ۃM���u�;�t�VS�u��u��u�u�t�@ ��t�9}WWuWW��u�uVSh   �u ���@ ��;��q������l����T$�D$��V�J�t�8 t@��I��u�8 ^u+D$Ë��U��j�h�@ h�N@ d�    Pd�%    ��SVW�e�x�@ 3�;�u>�E�Pj^Vh�@ V�d�@ ��t����E�PVh�@ VS�h�@ ����   jX�x�@ ��u$�E;�u�\�@ �u�u�u�uP�h�@ �   ����   9]u�l�@ �ESS�u�u�E �����@P�u�p�@ �E�;�tc�]��< �ǃ�$������e��u�WSV�������jXËe�3�3��M��;�t)�u�V�u�uj�u�p�@ ;�t�uPV�u�d�@ �3��e̋M�d�    _^[��V�t$�F��t�t�v�����f�f��3�Y��F�F^�U��VW�}��HHtYHHtF��tA��t<��t*��tHt�����   �5��@ ���@ �4�5��@ ���@ �'�5��@ ���@ �W��   �p��Y��5|�@ �|�@ ��u3��   ��uj�+���SjY;�t
��t��u&��@ �%�@  ;�uD���@ ���@ �   �U��];�u(��@ ��@ �;�}�@+ȍ�x�@ �" ��Iu���  ;�u�5��@ j��YY�W�փ�Yt��u����@ u�E���@ 3�[_^]ËT$��@ 9t�@ V�p�@ t�4I�4�p�@ ��;�s9Pu�I^��p�@ ;�s9Pt3���%��@ �̋E������   �M���e���øH�@ �����E������   �M���A���øp�@ ������u��v���Yø��@ �����E������   �M���	�����u�H���Yø��@ 鳾���̋M��·�����@ 韾��                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ��  ȋ  n�  \�  |�  *�  �  ��  �  >�  �      j�  ��  ��  ��  <�  b�  T�  ��  $�  �  n�  �  �  R�  @�   �  
�  0�  �  ̏  ��  ��  ��  ��  ��  x�  ��  h�  X�  D�  \�  �  |�  ��  ��  ��  ��  ��  Ѝ  �  �   �  6�  ��  *�  8�  L�  `�  l�  ��  ��  Ҏ  �   �  �  (�      @�  0�   �  �        �o  �  �ڌ  �    �  �  �  ���  s  �Č    �  �  �        h�@ h%@        ��@ &@        �@ n)@        p         P�@ �)@ �      
      �   @  ��@ l*@ r,@ J-@ .,@ �/@ *.@ �.@ +@ �+@ �/@ L/@ �@ �-@ /@ �-@ �/@ �/@ *.@ �.@ uB@ uB@ �/@ L/@ �����1@ �1@ 0�@ 4@ runtime error   
  TLOSS error
   SING error
    DOMAIN error
  R6028
- unable to initialize heap
    R6027
- not enough space for lowio initialization
    R6026
- not enough space for stdio initialization
    R6025
- pure virtual function call
   R6024
- not enough space for _onexit/atexit table
    R6019
- unable to open console device
    R6018
- unexpected heap error
    R6017
- unexpected multithread lock error
    R6016
- not enough space for thread data
 
abnormal program termination
    R6009
- not enough space for environment
 R6008
- not enough space for arguments
   R6002
- floating point not loaded
    Microsoft Visual C++ Runtime Library    

  Runtime Error!

Program:    ... <program name unknown>      ����rV@ |V@     ����    �W@     �W@ �W@ ����(Z@ ,Z@     �����Z@ �Z@     ����    ][@     I[@ M[@ ����    �[@     �[@ �[@ GetLastActivePopup  GetActiveWindow MessageBoxA user32.dll              ����Oq@ Sq@ ����r@ r@ �����s@ �s@     �@                    �@        ����        0�@ �@                    H�@             �@ X�@     8�@        ����        ��@ 0�@ �@                ��@            8�@ ��@     `�@        ����        І@ 0�@ �@                �@            `�@ ��@     �@         ����         �@                8�@             �@ @�@     ��@         ����        ��@        ����        ��@ h�@                    ��@             ��@ ��@ h�@                    ̇@             ��@ ؇@     8�@         ����         �@                �@             8�@  �@      �   h�@                     ����|u@  �   ��@                     �����u@  �   ��@                     �����u@  �   ��@                     �����u@     �u@  �   �@                     ����v@ ��          ��  0�  |�          ��   �  ��          �  (�  ��          R�  �                      ��  ȋ  n�  \�  |�  *�  �  ��  �  >�  �      j�  ��  ��  ��  <�  b�  T�  ��  $�  �  n�  �  �  R�  @�   �  
�  0�  �  ̏  ��  ��  ��  ��  ��  x�  ��  h�  X�  D�  \�  �  |�  ��  ��  ��  ��  ��  Ѝ  �  �   �  6�  ��  *�  8�  L�  `�  l�  ��  ��  Ҏ  �   �  �  (�      @�  0�   �  �        �o  �  �ڌ  �    �  �  �  ���  s  �Č    �  �  �    GetCurrentDirectoryA  �InitializeCriticalSection �SetEvent  �LeaveCriticalSection  o EnterCriticalSection   CloseHandle �Sleep �WaitForMultipleObjects  �WaitForSingleObject M CreateThread  4 CreateEventA  KERNEL32.dll  �StartServiceCtrlDispatcherA � DeleteService jOpenServiceA  Z CreateServiceA  hOpenSCManagerA  �SetServiceStatus  �RegisterServiceCtrlHandlerA �RegSetValueExA  �RegCloseKey �RegQueryValueExA  �RegOpenKeyExA ADVAPI32.dll  @ WSAStringToAddressA  WSAAddressToStringA  WSAEventSelect   WSAEnumNetworkEvents  WS2_32.dll  � timeEndPeriod � timeKillEvent � timeSetEvent  � timeBeginPeriod WINMM.dll � GetCommandLineA �GetVersion  � ExitProcess WRtlUnwind -GetLastError  WriteFile =ReadFile  �SetFilePointer  �SetHandleCount  hGetStdHandle  (GetFileType fGetStartupInfoA �HeapFree  �HeapAlloc �HeapReAlloc �TerminateProcess  	GetCurrentProcess �HeapSize  �UnhandledExceptionFilter  8GetModuleFileNameA  � FreeEnvironmentStringsA � FreeEnvironmentStringsW WideCharToMultiByte GetEnvironmentStrings GetEnvironmentStringsW  �HeapDestroy �HeapCreate  �VirtualFree � FlushFileBuffers  �SetStdHandle  �VirtualAlloc  �IsBadWritePtr � GetCPInfo � GetACP  FGetOEMCP  SGetProcAddress  �LoadLibraryA  �SetUnhandledExceptionFilter �IsBadReadPtr  �IsBadCodePtr  MultiByteToWideChar �LCMapStringA  �LCMapStringW  iGetStringTypeA  lGetStringTypeW                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  (@ �(@ �#@         �0@ >3@ �l@ �o@         �3@         �o@                 �a  -run    Load Balancer service uninstalled   Could not delete service    -uninstall  Load Balancer service installed Could not install service   Balancer    Load Balancer   \Balancer.exe   Could not open service database -install    Initialization complete
    listen fails
   bind fails
 Can't create socket
    ConnectFrom ConnectTo   BindTo  MaxBandwidth    WSAStartup fails
   log ImagePath   SYSTEM\CurrentControlSet\Services\Balancer  Load Balancer service stopped
  Maximum number of connections reached, connection refused
  Suxx!
  Can't create inbound socket
    Connected
  Connection refused
 Attempting to accept
   
   Can't create event object   Load Balancer service started
  8�@     .?AVios@@       8�@     .?AVostream@@   8�@     .?AVostream_withassign@@        8�@     .?AVofstream@@   �  ����8�@     .?AVstreambuf@@ 8�@     .?AVfilebuf@@   �G@     �@      �@                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              8�@     .?AVtype_info@@  �            ���� 
            �         �       �  �       �  �       �  �       �  �       �  �       �  �       �  �       �  �             
   �             ��@    t�@ 	   H�@ 
   $�@    ��@    ȃ@    ��@    x�@    @�@    �@    ��@    ��@    ��@ x   p�@ y   `�@ z   P�@ �   L�@ �   <�@ >o@             [@ [@                                  	               	      
                                                !      5      A      C      P      R      S      W      Y      l      m       p      r   	         �   
   �   
   �   	   �      �      �   )   �      �      �      �      �      �      �           �                  �  `�y�!       ��      ��      ����    @~��    �  ��ڣ                        ��      @�      �  ��ڣ                        ��      A�      �  Ϣ� ��[                 ��      @~��    Q  Q�^�  _�j�2                 ������  1~��                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            TEST.JPG   ���  wX��
���  ����H�Exif  II*          �       �       �              �       �   (       2    �          i�       ��    �   �
                                  SONY  DSC-W35 H      H      2011:07:03 11:56:47 PrintIM 0300           ��    n  ��    v  "�       '�    d    �    0221�    ~  �    �  �     �    �  �
    �  �    �  �       �        	�       
�    �  |� �  �   �    0100�       �    �  �       �    �
   �       �       �        �        �        �        �        	�        
�            
   @  G   
   2011:07:03 11:56:47 2011:07:03 11:56:47           
   0      ?   
   SONY DSC    "            � 	   l  @�       A�       B�       C�        D�       E�        F�        G�       H�        I�        J�        K�        L�    |  M�        N�        � �   �  � �     � �   �  � �   �  � z   (  � �   �  � �   �  � �   f	   �      ��    (   �        �         �          �          �     .
  �    N
   � P   j
  Standard            
   hp   1 n   �� VR   ��    �       � �?< �  ��" ���p� � �� �ױ0�p �G0�p �p                                                                    @ l   �'   �p�ppp7p7 Ķ[�2״�{    �p       i                                                         i                                                              �� } $li    � � �  R+�$    @�ܽ � 9 O b �  � �� c    &�&S��ܽ���  (XVa�~�Ê�i=�y s�f� tE�>E[�؊�� H  S �`K�[�X�X$TV�� 4�����X�E��3�8�8�X �X   p�\qZV4�' �[/F_�                            ��������     �ܼ_kh..????u                                � 9 � z � 9 � z   kw hF .� .� kw hF .� .������������U���       `                       �                        @ @ @  �w%<���L�V�iV@   �� �    $   /�  ��  ͪ                       ��  ^�  !  ^�    K  s  �  ��  �b  p  �  �	    i  i�  ӑ  ��  0�  ��  �i  ��  ��  Q  QF  ��  l�  V  i  ��  ��  /&  �o  $�    p�  i  �F  (B  9g  ��  ��  �:  ��  �  ��  ��     ��ppp��p���p�p�$8$�pp�8J8�pp�$8$�p�p���p��ppp�    �$p$i�i.p��c�����}�}�@�@{@�7�B2��idp� ���p�iqik�.��/^'�}a@.^V�O͞p^�}�@�@^����9|���A�M ��Y�o�)�o^}�@��������j�]q�v��������������������������\4\�/i ��{��psp;�D��i�i��� b@    ��d �{k �} ]   � p? �� � pR�  aD p? �� � pR�  aD    G  L9��3�e`�`nLyje�bLa`������9n$RLA�W�D��]a�nLWGK�DLÇ+]ALA�#e�DL��]2n��y���s�#j���Ç�Ń                            �1J��)c_�1=4R�h����&j"I6�t1J��)c_�1)c��h����&�t1J��)c_�1)c��h����&j"I����<�+�B�+�1L! X�1m^�1w��,B��fʯ�28t-b1=WA      R98      0100    
            V      \             d      l  (       2    t      �      =      SONY  DSC-W35 H      H      2011:07:03 11:56:47 ���� � 		
	
���          	
   } !1AQa"q2���#B��R��$3br�	
%&'()*456789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz�������������������������������������������������������������������������       	
  w !1AQaq"2�B����	#3R�br�
$4�%�&'()*56789:CDEFGHIJSTUVWXYZcdefghijstuvwxyz��������������������������������������������������������������������������  x �! ��   ? �g�uǆ<5�x#�e����x��K�����J���\'��a�2  g�<�����L�	���^yrAwix����e�p�w���ܑ_��fX�gJ5e+�4�I5��ݚO���{��C㸋Iצ��q�[�[o��� 3�J𶝮�#��l���� ��]E���$���e_���`HZ�[��z]Ηi�}oX��GsΠ�@���D�y��,
�(�����~���e�q�_T��ZoK�ߪ=,��*M9�ֶ�����ՙ��!�^�g����֊�f��Π32�
���=}�k�^6�����¶��-QeK�8�j� �tS���<7N��c��N�m�}���G�V�UOu��g��*<C��>��t��G������ u�*��=���񞵪h����-.���p��(��}��:�[�r��y�t%���{��w:��5$����������7��k�-N��?�m��JK�Z�6�,5a�m�H�6�b��3
��_*YH�;ƚ���x�U����:F�e��q�Q%��H�H���|�r��A�\�)������}�6��gZ��VnM�;�?�s�񿊼S�^i����cFѢ��I��O0i��'���z��$�܁��zwï�M����ﰶ�3咇sg�P~���mp��K��mݥ�����_ؕ��ߢ��g�>��/��	��-�̷֬�;.���,Nk�t[D�ؕS+9HO��˥y5q.�(A���~��yg9�����4,M:����a����c���W�W�l��u8�fq4��F2����߂+�xu���>�i5��l��u,�?<���z�@\]E
�kx�Di�J�w�%�9>�W�N];���&�	�W���Oa����~�m��.!������3�w���ӹ������n�����:Qt}������|�?Y~7�6��O�h[�-���671�$���$J#�I9p�H ���Ŀ|e�/���^���k\��]ܭ�F�g 4���e,�L�X�bs�
�=\�B��nY4��6���{���C,�.��d��wIi�C���<Y���^.�𖓠x�A�6�.������ �Z�8"`���%��+ц9��N��I�����"Ů��y�[H�9��T>\� ��]����,�p̞gA^��\�+5�ytV��Y������J�#����{�g�|n��u������Y�o��X��J�q��b�g�GR�Ҹ�g�>������S��a.�$V*�x1�I�`�!��9��]�q�赬���E�'n����s�r��ܴ}?��=����zW��-�����ei.!�ʈ��`�p����pEq����_���|\t��J�X��M����̩i%��>{�Q��Uû�}':q��9ZW����q�QXf���0�l�}�u�B|B��_�|uf�RkB�J��v�V@���� �!��k�<��crVk8o��l���m��A$� ��q/=kwo]����4ۣ=�g�1��MGW�H���}y�������UX}т�G>�����G����U� F��X�	�*{�A9�z�J�����~G�pM�U��$���  �O���٣���Ey`3�zWO�hi���R��xv�F��H[�I��$��	�^v	]۱�5ۖ�_��ᆣ�g�+w��[��O>�ca���/'Z�����wm���V���Gw�Y�p�*z�B��yTnE}�AEB�7���>���ښ�/�>=M�w�߷� ^�[��[�么�NGA �\H�ֽ�'{���5�D�7FG=z'ýh���}�iZ0� pP@OZ�t��$އ������y3��_���_�Q����m!t��":�����N�H�K
��$�F�*�2Te�^[��L�ig�I��v�q�|C���Q{����X�Lro��2�BpX��;�]ajdu���N��R�c��Og%����F�J.�=��NR���o_���|G�[i�Ƒ��{��Mp��+!.��3� �m����m��s�4��'ė1�i7Z<�jt�9aD��VE1��%�����_��;V��gJ���w���}�q	KGs��]�ռ7�y�����J����d�8���-1���]��-��Cw�B�rM<�.%
<j��A�H�p	�|�o��)F_~{�_���ѭ�%5mnΛ�^��R��K��%����yg,�Y� Q��w`я<T�ƅ�[^h��h�'՚����s#��'rN���W˒@���"r���C���1�I�����woo�eU�g��g�|B���|P�|[�1[�R��e[���'c����y[�`�I�Voƍ7��iV�h�Bֲ̌��Iwn|Am��G�}�k%'9}�w�� ���h�%����/���]c�_�t�}m���%�ÿ6ɼH�����J��X�Ėp�l�����g���~���x5�VP���� ��~���X��J�~ӿ��\��|=�������s:<���,,O�Q�=�5�_�O�^���:<�w����Z�B\���g�68�\Z�����=K�&���g	��n�����c�M*����^������ߴ?�|G��c㴜j%���i#1�p$���H�70�@8U\��eP�Q����l��"P�;%�I��m+G�T��]��r�����+��� wϨ�d0�H���k�uI��بr6��=�Q[zuܶ�y�J�@�U��2��UٕD�i�և���>����	4	���$�C�ZyB�+kib����r�*��ޛ�hБ�b���sJ�<Uy�xnO?BОS8I$KP�.��e�N�Ol����;�ce��bs]�yԂ{��˗V���|�V嗒+��#�����Rm2�N����N����>���z�2*�I[mZ�DɆ�;N#.!y�	8��������zw���5�?�|a��)��,A����{�z� F�Z�*j�"��⟧ww�E������L?*��+����O�{�|3�4����3��p���	+�?��y������<%w��о�yas�k�vk���Y!p�A��"�\��q���
<�������d"�5��wz���v~'�}cD���;kǓ[\;nWِ��a��gg�&�����V�v��mP����[���q��6�sF̬L%��o�T1݊��N`��J={�?�� &�~V=:���_Ӿ���X|�o࿏��|9ׯ5�/��u�Yog����*�dG�W;��`Z��G�~*��Z��t/��z��E�xcN���&����Tp�r��Fv�s_�c�+��3�뮶}�8�O��l�K�A�ޗ��@����hn�X���/0z�Ȓ�y+ ��OZ�	h&����R�7R��D�0������<��rW�'8R��=~oc�������W��������Q�]b-d�D)�����l%���Kc�F?��Y��:�ͭ�р,�e:���h�O����c��)�]r�}ߩ����������h��k���=����Lr&��C�|��x�|�������Z֣�w�s��wrI��̮'����E�O�q�
�r��Gٽ޿���'�<G*��E�߫0��K��27zwT�N���jr���ڑ�Q���	#���#�5f�pz�F�������b���#��YXi>+4z���/��D�(�,R`H�H��6�b-_[xK�w���N�5;M��1wo��.�v"�ߘc*YU%�8#i�� �~���2
5�-ճmI���8[�Zov�Zs;tg��{
U�)>Y'e�뺶����|'���|+�֬���I���t�+��ϕ�h�b�Ʉ ���5�~MSó�9�Ь����nq��T6
d*8�ۚ���5,V_��;�8n�k��Q�9�!ξ��9]�O�s�
�K�CD2�bAF��H�\>~������zޅ��C���o�>��{K��6k��-F�J���m����FAȯ��7:��#������}ϼ�G��[��� �=��B�|#c��G��/��Imm��0nMU
��a.��J����F�_����� �@�٫x��z潶����2�=΂�DӨ��P+/�2+�Pw1�\�po��νT�[r~Ri+/7{�+�7�񳦬��y������7�Y�;�n��S�����o��Y�p��9����#�2$�ϼ�C�\�� 7� <1���L���_x[�W��B��G���Q_��m.��Uۆ_1�$�c����=<.�MdԒ������^]^S�$���/�	�N�� ���h��v{��|��X�H rG�;1\���|L��y���� E�=濫ڦ׶���a�IdfXS'�>�_?[z��W��S��j��iR��5e��� �S�6w׶_ں������-�W�\�E�B/�F�(0Ib=��غ=c���¯�Z�� 	���kk�+'�1,:r#`^�G�� ^w|ӫt�g�c�)�m��^�?�
�ÿ<g��Z�����xn;��v�:Ɵw	K{����a$�U�`3_��f�q0���Q�������Gݎ���4�Ԇ.Tdߺ����V-��Z]y^�~� ���r;�+)�Lh��3�����⦒w՞F3GdJ�L�'���@��>���l��c�YN�ہ#)��u�tEk�y�}O�O��jz�P_�������g��S���qh�2\�m}� _��s�W�|h�|:�6Z��ί�����k�,n�kYA,��  |����9�5���xZ�p4�cnfڻO���M��}O�3
R�i���k��!�M�$�,�uk�:=CO�7"(�ȏ"�!G�T��x5��2Ե�K�df�ef���u;:g���+���J
�YZ�O�?�nx��T�V��N_����΁��w�-Ǉ�e���G�uF�_�:Ŕ�v~�I�5��p���C"��p2������O�'_�-�8|9���}�?� �A?��>+��\��y���σ�w�Oh���+rYZx�������2��b�<���N�7Eog�_����S�'��%j|��\~�.�C�,�6�����|m�o�<��&���$�j��j&�C�Q9I-�-g����I#r2>9�x��?�������(�A]m5];J�.mb��%Zx�d2G�WX�s�b���g���k����D���7�W�e��NOd��]���� � m?�\�8�u{�k¿<@�t~��n�K�mV�N��+�����}����&"��>��|=ዯ xsP����V��~������ +��?�B� h�#��\��D��u�l�1�jr��Ӷ��;�Vj����T�vz��?���%��}+X�o��37�5(5�R��H��I.���Tp��og*��}��~��_� ����lo�9�
�ɥx�đ@�&����Vw��}B��d��=��,Ȳ"o$��y��YRs��䮼�_��}�K^����Q�ׯ�~�~������,�"���=�c�9�	�Sǰ��~-��Wp�ZM�k�M��E���"/�]Uaoݐ~7���/�'g�kO�'Q����^��M=�Z��M�hP�qmm�����Y�	 �@~�.TS�9�Z��������=�U���T��SO�]j���k��c� ���o~2���x�����F��ެ��[��y��C!���bWx�A0�W����M����H��)���S����[��u;G$#$d0`��yR��fx�F��ϯ���S師��1�V�*�4�m�OvM� ���O��ż�ak{���� \�|��<-u��%��ve1�Տ���ӊ짶��b�.�'�Z����Kk)��yX�M�h*>���䜮p8�5�������_�0�x��Q+�J�r�9�� ��`�<W�
R�&��_����4��m�P����X����|Y�n<1'�u]GT�k}=ne��ñm��)����Ы W�Ǆ�j"����L:'�l���V�$�@�M���� ��1$�9#��QxW�^j���y�JyӅg)V���^�q����[�����cZJQrw�ʺ?����|ãx:KM�����4ZΓgi�Ș��B�NA(N��v�V�}�T�n->�;X�1�0 ~����]YT˱O��׼O��0n�+���Ǌx;K�VVp�:_����LK���'�3t�lc0��<�l �� ���� �O��/���O�#�g]M4�;)�#�����|��#�k�ve��T����"�-�|l���V䜗=5��gyI$⻦�w�&��c����yd����i�q���o~i0hv�#�ֽ�|?�X������w��C�@���K�̀�|�M~BM}�Y�&�V���a�R�[�NEye����u�:����1����px�x�B�h�0z�i�OO����8��炧^�\e(��YY���O |m��1���=3W���$vڎ�e���q-,����R۔�Tgh*~º���j��� �?��x^ԴDt�I��֞��vK{o$`���8o�m%I�^YQWR���+��^� �O�j��~ѽԏ�'7��������O���c-?Q�G����T�jz���^%�,#(!���@wt$b��I��~|<�����<	�ߌ����}�vP�`�wsB�Y�^@�s�9 ����O�q�/ɱX�]UEa�/y�e�+i&������FUaM�'6�����O�~+�k�n-4��1|[�Cv��c��>`���$`�����?��ψ�<z��x$j�2�����L� 9Y#���w�[!�2��_���� �6�\�(��`���r����e9.{ݩ8)��I&��?��51|+�������X��}�ݕ��5�}��������?��տf��b=OD�<Ii��OT�v�;ĆP��yt�!*ѷ'�����:ׄ<N� <��KE�n�c|c����9'�i!جΪ0s>і˦	5��d������pv�����[_+���
�����o�V��?'�	��E �PX�&}�OБ�\G�t=[O���� RmN�v��h�ln뎃�"���I[]���ރ�Vf�Í�]���%y1n��i�̤n`�q�����>�I��Cތ#	=�B���r$nNxS��ȯ���*�5 �⵿_C�	�E�j�c�6�C6��d���G����V����f�)R��!V�g8�7��W�W�|[�]*������gD����V�R�ZEe=�P�g�z�x�pI� ��P���X��h��R�
���R	n���+.�6g�gjXZ���+^����i��~���|=�h:��<9ԵX�K��Epv�Ye�ieI]0��+1�#+��#�Y|%�]Z�����c���X_뿂U!_,�Iu��m�G��y��'��>�\|)����Oҿ�H�-]�L�ۮ�mn��ay��������_�����A�٣�V����/���߁a]_�V�]?L��3�mi:�.u)���B��ѫ�.uZ�3��/v�M�nT�o����/)҄"��~m����o�{�(������׼%}��;�\Zo��/mu$��gN��2)K�f�i·��� ����o��C��,���~������-�H���1�)�Ɉ��3r0s�eU���<��s\��z$�R_?S��V���h����\���ԡ����_҅Ʒq4����I��b�ow9EU�<0����sY�� 
'�:w�|I��E��u	��%��������-�F��ٲ���pk�xOB9��F���o�z%��g��!)E�]Oh_ۇ����~)���Y���E��.�Ia}J̛���>D�]��Y��3����(���,��4O��#�3�?��v���s��뷩)�ae�!BL���*.��9�u����)Ɨ�n/���|�I)� �[��}������V4�l���_�S���,�v��ܾ�|7u���x���d/!N�xs���|�u����|L�Z�iV�����.���X��''�Z� >���ь�dN'MQ�*�9IS�+(9�T���w'$�we���58U�:z���:���Ҵeuk�ON������h�+���b�Lћ\��u���o \�9{K`����}����_�w�[� �?<�_���O"� B�F��7M��8�đ2��"�ۜ�J�Jӷ���d��n~1��uj9f�_��vn�_������#�������w�������oV���e��yrg������ln$o�F�xg�dl��#c��_��7&I.\���u��<2q�tS^�m�\ޛ��}?S�ͺ_[_�v[�o�nH���[�g�U2O<cw�7��1���G��́5]Bhsqu}3(ށ��2H�;/^k�2hU�ܩ���|FaR)Zl�C�Ԟ*�޹=��%��坝��Mn��-�� ?�EG���rX|���O��*��
|q�O����C����T���<ھ�:�#1��m��'���M���j</��27'���)�o(T�$����Jm�̜}N�RR�]c&�{4��k���{��J�<]��ǁ��cK�u�]?�z���-�lL����+���'�A��W���Uo�<� p�����G�z�Q^�D�)�����מ�{��YFK�������υ|����J]Z�Y�9ª��Y�w�?�je���O����]���/���h�4��� ����j:���f�R8�,JĻp���12�i[{*�����������T�V���� ���i� M�� ������ψuY�*���p!:n���|���Ysx�y� y#n ��c� ��~=������ ^x��v���]C��0"�^��o).�`Z6(�b��	���J�܊O0��x%�Z=,�/3jW�t�Ͻ�ki)��Z��[�� �!�3ÿ�]�m9����ϫ�i�zth��8��kh��b<�U�O�KL������׋a�֋-�����xc�3A��X�c��H�Ī��d�ۏ�GK�K��������ugk}�����(��k��f�� �֣��|I����+�~��V��lg�̖���̿�.5h�v��BZ��� f��o�>��;��[����|+Y�ee &�H�&A�%6���&��#��0�RJrMsGK_�������n�͍����Gg��x�BOi7WzM�q\ǘ����NY�О ϵrx�J�~��i����h�L(���-�\M6� y���%#�ʀ���2�g�|NO��jT(��K�Ӌ����su*Vmʬ��57+�h�������F
��r����9J�9yF��W��g������_�O���5/55�b�XR�C)��lN/Q_���R���� �c�������o������/�M=������f�x$�H���3F��Ww5���*i�k�w>O��':u1	�;~��?<{�]���{�?��~']�|~�+�#����Z�d�IUD9,��^M��O��i�:�7�II�s��F"��b�1
�;����d��֜���� ����f�U�
�����ok�x�ƾ�����l�MzY�I�*(�Ef��ۈE}�X]�K,ѬW@��z }+�r9)Q�٦� 3�3$����\�����mӼ9�rO�Z2��%�j��衈���v�Ƅ.`x;s��q�_xR+m/÷zm�k�Ȭ���6[j�^IF��c�E�&@[ m ��;��YZ����_�G׾��w�i[�j�Z�Z�tz�>i��g4�ke��[��]��� ���ڿ�� ��/.'I��'�E�)��l�I<�G�u��>��~�0A��X�� � f9�y��2k�T�Ed򨕹�'�e���?�x�|����~o3�7���ƗÍ�A5�K�M͎�����3���ᇂ��������3F�4���w�fSy�k�L%Ie,w`/z�/�J\ٔ�{6���2Q�}��j�۸2
4Tֻ�� #�+�����?|;��>��H��2��,�MX[��O���ȩk�KH�|��@
a�x��
|kg��X���_�7�׋�6�Z4ӻB�`����X���y��lO�����0U)Νnj|��ӝ)E�z�F���z��y��%m~z��>T���Q�>0���Iŭ:�S�"X!�E��f+.�e.�6�4k����� aOE�_xcT���/f�� D�t�I��v�6�h�C����� :�ʸ!��5�)�*)T_z��[���y�[��_ש�� ���|�*x�E���i^������cjEǗ!���mg̎��<~�~�?���?��="��/�[�]F������n�q�2��U\*�s���$�/^�=�9��oO_���|Ζ��'���~6�_|U�-kK�L�)�W�9�cw�}D�e���%���%�cB��@�����ԯ��_	~"�C�>x�ľ4��{%�ߊo�M��N`�ma�R��m坡H`�>r~�SR�`��ޛWo�������Y7��	Q�I&�w����u�?%k_xK���W?�vz]Ž��ec��>�`#3�XC;��pZL�����ƿ:� ೗���>-���7�v���/��v��Iax�3Z���K-��ʬ�n��%L� �+حG�<���Y� �F�~����Sq��o�2���~,x��L�F�(����4�nm��6��:pJ���O«o�ZW�ol�&Kmx�ч���"k�A��V^0I'ץz8��
�k��s��1�^���ϛn�7�5�G���ž�o���P�2I��Wms�jY�b��,�S'� �_CB����W�g�ZJN�?h|?���?�i����_�:AP;#�̶�~6vZ�E��a������	�ay⻟x�K=fxn-��l>�ԑ2ʶ���v�(�d��"��O��FS����9qI�yrJ�(��Q�����=Ϡͫ��h:1_�������O}~��?���"�>-x�o��6���dCae���� ��N _����f6�!����KXr8,d�{��ҿ�n�ɒC��{g��<�K��+�����i�K��e�v�'ɻi�h%i7`�ѱ �x�_7x#����|O�i�zΓ�.o��;̊�"�1�*G"� ���s�_��s��s��Ù)&��I�������N4tz$����T��|?�=h� ��h�Z��]�5�ٵ���]��G3F�6ɟ ��,x�_v�K�_�1k����_����ar�W�����A�$@�
�~g`�׸J|=�'��ww|������X��9΢�ފ���_y�g�+��L������<Aew��v�	�ב�L�NO ��^7⏆W~��Ů���޻Y-����Q˸�J\A��!�7u�k���{Iٴy�$���~o~�� u��KK��n��r,�5�w��`X.��*�"��'�����d�W���S�^x��6��ۉ$��5i6�@��D/  �d�c��Yb�+99h���:׽u�7�_a��O��<?�_���7��.{�����O�@�}��RYd!Uwg�!��� �����˟�~���zV����-�=lP�� 	$��8�ԟ*o2L͓�j�!?v��n�J�5��Ks_w�+�I�ft�^5>��_���Ӫx����{������־:j�$��P���Io4�+L��<d���2� ��u�|E�@��2Cmmt����n����;m.�@-��^�Zܩ�o�Z?Ty����qٻ����$H`�.w��l��J��-u�Kq�x��H� צ�{�y	��>z���6�ѭ�Hr�>g�����mN�,��K��y��t?*s�&����e[m�R�.���� k^�G��8���I:�"H$�̄��x9px85�i�'�5]#��z�:�ڽ��y��g!E2��(uuHԎ����_�F�t�J��t�Ud��Is>v��溓���� kW�0�-cu괷�����	�CF���/k�	�g�����)	�Uy��-)c�%���z7ǭ��ͷ��M[�r=}/��t��#6�H�j�G+�����UH�9,8��zu)d4����sw���gN�i/l��GO���o�}u��Ům��t0��t8�I`23�^]�_��?����5/kZ���3��~��s����e�Ir��x1����ٖ� mU�kٶ�9m��?M�&�$���?�/�|B�Ӽ#����,O�A6�`��!2H���X��J�rW��~7x�������k��R֥���O�$���:���F,şi��$�����"�F�YE$�#�aJ^��Ou��� ���[�o[��m�	��G�";]#Pe��KF�VyT6�V����~/������߈l��	�{�0�i��_�4��CK <	 ��aK0�R6����.�{W</T�a��b;�s_��֭o����-��$�L�nK*�g���?ះ~[\��i�6�#o:�[{�V��7g�C�0����儢���S�2���R� �Ge�ZgO�i���=�m�#� *����\<�p7d㨮���n\�#�-,�Ωt-�๕���U]�y@��� ���W�G�t�U1w���9�̛�F	��u�
]���;��-J��D���n��?�_i��ݢ�Y\5���\�	��旼��2vNH��F{�>�G��D��wB�RL������J���I�;k8�Y,w}r}j��-��2}Or񗃯������'�m-�I�<ۥ0����uf�� q��+��=���߃�1mk�x����~�F� O� �����n��?|�QA\�wH� <��)�q�)kQ9Z���}^�]�U�e,�0I���{��m�?P?��w��� ���uY��L�,�ڻ��D�%�@�<������n|c���|x�˷<���� �� E28����_��vq� #y����/��P���<c����(�s�O1O5�v�<(�-���+Ȭ<i�*� G��a�Ow��h�+;�%�I�|��!
�G*Hc� ��h�ζ1�:R�3��#���
����>���|W�/��4񶙣�q�h�,�v���!{[���l�D).��\)�¨bC��I���o��5����������S�eE�H�T!uB2��J�s��#���{V�C�p�w���]Oc1�*xU)�]�� �3� f�B��O�|g�_j��{>�{2�3������!�[�S#8U#h���6��'�h��os,�4~b��E��
�e!��f�YT��N*��|�E�M���g�����w�x�Jյ1��Im!�4����A�F��8�s�e+&�# q� ���}C�~>���<Mq� >�8�Ҽ7�F�K�bv ���py�y�����ד����j5[�ϣ%��m!�xa�� t��מ�jq�x0���n�:���x�U�����ɑ��
v7�A8�w������O&���mq�+ܼ2ې#d;T9�9��"�5�j�z#/ZK�-��!v��I��>�F�y��N?j2���w7Sw�}�}})����f
�^�<�R�o�����g2�
d�u�_"�����\�|�ܫ���Y���z����_�k�/���P�����O��35����Ϛl���.NHF� ��|a�-z�ᯄ�7�o���M���N#�K����9,r�N�wW�i�
�p��ZI��R��Y)���ݮ���;�����-fڿ�I���{��}�� ��f�?eZ�]m��~�%�XU	�ʓ_/|J�,|A�\H|����o�����k�Qʣ/�:.[�G�G��k�5��<;����h�*\����L�T��iNᎤ�LW��W�-N��ltSO�[�k���d�R ��r	�_�\cA��N��P�iz[���?�8N�����w��� ��֟kmY>4�ws�}��U�D�KkD����[t`S{~������ }Y������������� �G���
�Y�$�##0�4�ܘ�PKH���x[>�R�߹:�m����Y��NX�ۚ1��\��u�S𮡣�O⎹�J�}F��K��^	I<R�F��9b���^	�B��M�����Z�sԾ\1E�y��9,3�}��,ܜ�׿��T%<?-����f��|ב麥�}y���Kdږ���W ��ϸN|�I��>�o4۔�h2FYc�$f��#ߊ��z�S�|,��6��v�u5�ga���ڸ[�)��\H!�	���TZ[}L��Zjv76��-��9CdAS�pA��-��֝Luh#�n�$B�Y�-����.qӎ��>֬y����|����w�N�&�|�������:6��K�y!�]�Q��@�4����u9�;٥�Y���#�}q^��_�<YF�m�����Y�y�����c-����&�ܽ�1t�\短54��V$�G�����;�x���Λe���,FF�9�߻��RዮFw�|�|{��� 	u�x�]U>%�\�M�� g����S��$��A��r�p�l��c�q�V�a+.f�q�d�ݟu���2�Q�+��z__����A��A��xMRٵK�V�Q��?3��y�<������<_���$4j�yu f|��x+��T� �J=�W�S��,�nZj� 3�h�[k><i���U��Yʕ2*� Ձ;�ƾwť�Ǎ��r�����ͯ-�4�����8�'�:W�g��UZ�Wri|�I�@p��E7����(�7�/'֛S�����唶���e�g�Ve��u�>M*��Xԭo�]e��'`֬A��+ϧ�_I���΅8����뒓o��� x�n���� |�^Gy�^�A�@��q��%�@?z����~�|E�<mo�k�X𠴿7�KM3B��84*Au5$��t���iK�}n{Yl���~�[����w��7|��kwҮ����l�"���$
� �*X����A����9�*�R����&�AL���j5{�Ne/���ncHYNA=�/]��f$�����Ehk`�f�c���^v),��u��z�$[�ql�" $q˸s+`%���\
�q��ͣnY�h4�\]Elѽ��I�z��^�g��1�<0�շ&���������0�����۫e+��6	/����<f����Riw��ۤ�0�������b�Q���?���� C 
(1#%(:3=<9387@H\N@DWE78PmQW_bghg>Mqypdx\egc�� C//cB8Bcccccccccccccccccccccccccccccccccccccccccccccccccc��  �" ��              �� =   !1A"Qa2qB���#R�3���4br���$SC����            �� $       !1AQa"2q��   ? �� �d֛p;�c�v&�ܕR>�OI��h��SU��I��1]�`���� O͆�el�x���W.z?A�	���;�Yy缚4af��� ����%�$9|�i����j�؊P�Vn��+(\�a�ZjZ���n��[��?a�p�]z�.�%�J��,��60k�� ��0R�Y}'�`��Fw`�e眩}�e[@�'��<���#6�8�B(�9����qӝ�`����=�#8ھ���Ud��剕Zl*�`���%k��@$㓉��]mA��� �i4�˻�9#nH���<~�'ǮP�د����:1`�62�F;ΥU�wecssט~�#*�G'�{�3�=u�F��$�'WBT�
���I��{D����h��5�ے\�'�����eX�� �7�W�����Ǖ]���w�[�5���3�t�F�N�U�=�q��-���u��U�3^��R��q�/]�v�ܘK?�{��&��%I#����D��tk����u2Ƣ��7�@�/���J{rln�|CMm�,�O�`��p�ygMg�Im�l>Y�zt���<�}�O�0L�$0�o���r�fw�'L��[y��I-�	�m��2�8<��V^ƲC�W�:5*j�C?�9w��&����,s�x�|�b��r-`8��&��{oU;x=ex��0�wg����1OV�TK��{���o;}9c�j�i�V�bx�W�
�ȺἎ��-fgM�;s[]X� �R&o���'����z�p��<"��X�cc�3�)N�u�v�q�[��&�T*q<�ג���k?�Dأ<���S3�50f*��N�U*X�f���4�z���9������JM�l�p���٤�V�
#'�t���u�`O c�C[e~Kf������>N����<gۊ� .u	��NU׻��'��i�jK��qלg7Q�^A���3�|\��������P��E��������ܯ@GQ�T<�ޤd���C���Ul��c�IN��p���{d�h� ��e��V^컋g�`tt��I���&� �v~GΌ+[
�� <�����ی��(���lʽ{����^S1fUV�!��q����V��$����W��MC6�����k�����2$�io�j %� e}!A�@����k�%����G,3��b�ݍ��tl�"��rYO\v�=Oio�CM�3�ѷ�ϴ��l$�zm���fn2��{�i�Ք���G��t���ܹG�ji�Yr]�r1�K�k�VQ����Â�[����}V�~���*�a�%boZ�gPV���h�[7X���J���E3���>���9j�j�?��&b�yͻ9a�&�m�ۻ �*���}�~lV�Am��p�F@����4��?�۸���幗
���l�J���N_'�^��#����̫���_�+�ߖ��D4�M>e�nPpPu�K�(�>��-���t�0��u>�31���k��cc(9��%m�S����z�A����3�1���I���-&��Å�p>�`%�8U���io��<�r3�� 1��~������� WS���Z�� �����z��\{�X��S��m�=��9Ϧ4�cQ�� ��9"J-b��n<��ic��v{��]�Xv�'w��N��;t\ն]��p�<ʙ�[@$���9x���;S��eG���`9�>�}�N�ӡ��]�eU=8ăY��v6���L�p���K/x/�%��f���eK��z�+UpZ�N^�>b�5A�<�:��Y��	��k�K��t=��A�,������2O���~Qo{0'�%W���P8��Z)��cθ�#5v�#�~>�[4ŵ��%;�=����cK�Wl�Ś�c��N��]y	�:�\�(�H�%OAת؁UG\�:Hڤ�U-�\J4�HYHbz�ʑh^��|%j}[vp�Y���7]�R�lfn��H���ڣw\�+m�,0z�1���.;uk�y�U	��b��ۉ���V�k\y�`�I=�g�̭[l7�՗ʻ��E*�^����xWd�P9?�-`�@;��t�N9�>6��n[<Km�0�P�=I9��m-`�������=��+���=����.��:{Y�� 98���g-���1�����n�e��=��GR8�� 8j�a����yk�j,a��`fN�u�+��'�b��S4r����b:��J�F<�僜u�J���s��#���
ٓ�^�[�y�P3r ����;ZO���m�[2�A��-�I���ؒ���z��?Z�S�7 }��⽪��xź�ĝʤ��ϙ��>ӟ�z��I�[�-m��B�t��]E~�0l������;��%���V ����fWS]�V�|�pI9����C�?bօp8��g%�@n3.�ͻ�=�$�ooۣ�3P+7m�I�S�E��ޡ�D�����f��M�Pz���5e�,��F�u�ZV�W���ͤ����7��\�g<牎�}�H���\���b�a�j��8bg�o�o޾�O�	�굞��j+� ���H�p�e�T���j����XG$�����`����/��z9��\�Z)A����&Q�(ûc#����m�2S�����R�`t��辽���� C��x���ʊ�sc'�!tz{Yö@S�G'��:�����%�ڸ�8^�������[�BIf��7�UХhkǑ�����@�
���O\D5uU;ڥ�'���]�e�黟�!��v;�鞲��CV��0%����!�~U�2_��v>��s��� ���Ύ�Ģ#���#/��/vS��=����yDc�:��t��Iq�g������_�"�=�"���uGz�w3�^)����#��3���i6w��O����K3�#j��u�i�5����� ��	u�#��4���� ׇ�q� َ������a��RX�GS$��,j߱��j�{O^�?z�W�?��5h�P��w�I2ƹ�V���=N:	��.-�hي�O���+U��?1�2P=��;�ׄ��t�`e�.?n�999&t�S�z�� ���#^�6��h�8��A<��cT�e��6�Y����dYl�����Ea^9%�?��_Ps������*�e�H�dc���@F[#?#�s�y�K�郦��,c�9]{jF��9�P�F@>!�z��n|���l���n�gP��Y��` 0�$-��e��#<�9��\5�㎘z�)�f��A�o0�P<}������ c��{�G6�
��s��ʜ�u����x^�K6g������DX�����L�e}�����i?�3����mz��@w&�7aN}����x2����l��$�lO.\�b@�A0��N�x ]�A���@
�1�&_
��1m`��LصY�P��c��z������5$�*��'�<�w^�*0_�;E�Uim�@؎]��$�'Gb�ƶ��b��6*�E4v������1��4��W=Ff��۔�Oq�с��O�i\me=s��B�����c'���D�#�T��α=5��*�S�	�h�c�-��pz�S'V��X�Ҵ�1�V����b����U��#��OWQg�T����\��A�vp3�W,���'�rq�s�'��G�3�&\s�)��uO��e�)뱰0{@�2�Y���M/�rz�!����Rʣ��-4�B��K4�P���7}�lQ�m���FOH���-.�-0�8ñ��7_Q �'Ҵ�� bh8�+x�G�4���u��Q���'��gz��ey8?x�� e����f��\¶Nw�����1�@${����.H'����}.,�-e�Hf�q�O�H1V�ǬOX;-.��8�o�_q��z�Kj;y~�DUY����S9��	�~��H�cTp1�w0�ǲ�3s�;A �������T�樰�K:��}Akrq�1����V�Z�sɌ�z��� Ph�����`2@�5^��SZu��>���%U�����j��2�	�9xM��=���O�s���ֲ����g�U�:�s.��-�2�>���y<ēm����=>\uH��C6.�A�Ӫ��7��DE� 3B� �C��&��h���l]� wp��b~|���V^�����3 !��P��	��{t��T6���k_�6Mq��9O��g� ���E����;��;���'����ς��C��f�u�p�������,L_��yW�� O��5M���Z���m��H��־�mJ�I~�_:�K}+n|��u�HW�SX� ����������[�9����/���n'��{X� u�g��'e�/O��]#�����,�jw̿Em��Y��u�+`ʏ�����s���>W;I���5g��:Oi{U�pd��=�au�3�j��L�xzm�LM_���K9	����K��̫4!zf�*q���y�\��3k�3�݄���s(i���"Y�,�%���v�1�SX����3HN�3�>��Y�l4�=�`���_�s)��������SU��̓eM��m��q�j���E��O~������ŧq�?��.���5ă��>$�nǨ��M[P~�{g��u0��2���a�v#\�ND]ݭ@8!���5���y+e��H�5�>��k.o�Z��E�7�{N�Z�),���R$�<�s�������n��$�m�ۢ5�STJ�dF?��{nR����{!h40�Ҩ@u�~y�Ot�Y!����۷!�����d�:�k�-���zd�f����7������h=���돉�͞�����ߴPYg�Mm� )u<Na���B����b�}� ��}����4��Q��k�/�%��B�����Ot����3��0ȸ�����[�k�͠R����֪�5M���z�1�7�����o�"��ݍ� ��Y�lޱ�Ź=a��D�Ec�C���p{�\EU�$6b�E�"�ϙ�a��A3�'�ۓ�J
�	��b	��	������VY���rq�%���6�y�dOy�Hc�|M3����m�m�Z���/���!�RE��36���ָ�d���q� �'�lL��<M�Du�6�~�z��Iyk؁ �ҙ�$��&����ϱ/jJ������_�#�f7`�9x���[|�;@'��>X�z�@紲DI"��Z�a �9�e�U�1�^��{��1��u蜣(v8l��Ժ}���H�Sgn#�R�+�~?0��� w�� ��a��жV��ؑ��2iݻ	�/�j��q�u`i�Q��{:� "�G=���X:�B}�H�c�;��!H������M�#�u4�����Q��q4��~�Ƒ�1�,{��	跑/�>э�^�%2�>q̳I=s�BиXQ�4*9�X�0��n�2db5<V��1�Be�BOP3.�'��'P���1(�#L�'�3w?@�+�Ps�50'���b��;/��,�aV-0����23\�Ԑ�J �b�L����h-���^���NkAG~���E�4��DX��c��ۿMNi�E��f�P�k�ܯN[�2�v���� kX���ǘ��D��ҭl��Cc��9�@e��d���Lp��`O8F92 `�&o�<YiAr!1�aT� ��j��l��r��>b��i<.������ d\*�״�Ǳ�� ���:�h�������F��� �ə�ɫ�yV��x��i��ӡ�:*��o��c��qe$*��jY}�0(=L>��R��� �T*�-�?lE�X �GQ�X@�RA��D$��+���������n��~�r���c,8#?2i���'M���q1[�pJdǼ�1<�|F�|E��͵\��4�\�2����|�#��֫�cS��� G�!�X9l�&*J9^� �=�cS���b��9������T�Ik`V��[S��ۃ�c~����q9?�H�NN>С�j�:���Hcι�Dk.ݏ�����1�`o��z�|�:��]{� )�OcǗ��"ג����X�П�kʯ�tO���?���!��6 ����&�f���}'����8L�j�yF'��pzB�I�L�}%�6�� �d}��1�be��`���'�T��kͱ�<�ŋh�It����z�*�5g$ y#���_��ƪ�w'<� |G�7#���L�Ò�b኶A�xn�S�}E5;UX$��=���"4��bQ�>y�ۻ��L��'�j�a��P�u�K6��8��o�Η�_�x���%�ҋ
��>��*��)J������ɓ `��:�7W/�G�6��d�����d{M&mA���_��n��  kp�"�̌��;q�����C]�
��4�5�F`�E�Rd�ï�Ǫ�4.���=zæ�� ��X��ȚV<p"�{-.�`w�>�	U�GH
�X�2�~��&qR�;�#���`%���>�6'����-�89�bo�B
�Xo�̺A'�L���y[>��͸*�=�^�+��@�����"L�]d�=!��ܐNf+ܭ���c=tbѶ#�q�G�Q�xvb����H���%�����p3�ktmXS�{����ld�7��S����3i�(�e���y��9�xP��$+�̕8.�Ò	�s::jSH ������s�y�q���FЁ��Df�%Ie��ݳ� �0A�[��8�[�z��u��0���6���6t�5��嘪��*Ȫ��S�`H�>fY �0O�lX�@�6U[91wV�r:�2+9�:�H�0H�ǩNǾ#�T��k�p=Y{�Wa�mıF��k�d��N'F� ����s�s��Lx�z[N�Pq]�*O�oo�k���^mUJ��&vf��Ȟ��� �(ֆ�I�o���<{�.�Z�=B�Y�)���5e1[�t��2����=KYڪ ���M=)Z�ʨRʸ�;�8�u���dy_����x���8ں��n�i�t�:��y�k	��X�[���w;�mW���?��R����}_���4�h�ʕ(DA�=�=�6��p��<H��&�_�Q�;����&<'��5>+��V}/i#�3����Z�Vgn��cM�}M�U!�v�'��h�����5����Lf�ǉ�-%�=[Sr�u ��8�"1b���\��K��$�2Un�	��Ջ����GB� `B���a1��99��Z S��F3�j�7�i��
����� �>�x���[We��=D��3�ǉ �����)�_����9��U�k� �XF��;@"oIh����;�%gq ��s�:����U=��	9ɛ<���h�6L� X2���	����e��K=�&�	��H�&�Y������z�0�wė�F�(ڠ�u�����wm�!�׆,�36ϣ�3��t�Qf8��ɱv�.u|4U^�����m=��y\K��`*��exgc�ƵMz��5�_y�?���_Nc�O������(�X�wf��]�j1br=^�[QVgS�ݶ)�M܎�2͈Λ&�����#�j�[,
J"����[V�S���G���	�=��(Wj�jֵ@G���=�{�S�����r
����ie������,�Cc+�=�_�J�'=�1M�UQ��|�,��%f��ϴϗ9��it�p9lp=Ǽ�*z�	��cB"�b��Gy�`͞`�F�M^g<�O��� k�v^�_��9���5nl)��~�B���8�1:ְQ��ږ���q�
�H�0�fg�"�t��h�c][�}�/;Oq-��=�� �9E�Y�8[=���^��]>�@R��L�o]����{{�τPY��V�靖g�� �^>O�[̏W�MEZj�U���T�w����^�L�������d�S�\ΦT�@�۳��L� L��=g	�ϋ�'������a<'���9�߆�����ɞ��u�]O��Q�O����.���{�a��O�s;I����	��&��b��������G��Ə�j6ןçо� &1�>-��F�ҷ���~g%|3V�����%�~��#q��ڕ�F������5����O�eu���36� �n>�Q]�#������Y�G�Y����g�6�mI����G'�s먧Y����h�8]�21�0`'��̹F<ҚÞ88j��,q�Kv9럼����0���H@76H&T� e�����/�-��g���%��c8�d�mP��~f�R�#�5=�~�-�>����	J�NW ��X����f�̲v9�2�*C����v�mc��L��P,'u������K�=�����o%F�ٝ=��Z�r��D�K����@��.��N���������UJ�5$12S���9��z�}_�E�ދP��&��EΊ���C�w���� ��*��[?i��^��rTHQ��֯X�Y�W�f� 	^H�&���/[�`
/BGS5�b��k���@��i��y}�@�tK���F`�v1�tú� ��T��q5��	]���;�}�\��0�kQo�p����&z瞽�K� �.嶓�v��%u!�	ٸ��[f�-A�w�����檐�q�n�������ܽv�4��K7��T\Ke�=3�m봝�,Oq���̷Mc�;���o��4�í:��I�6�^����v��rs���5`S�j�Q�F {G��s&�:���LN���itz�P_�h�=�pķ��W;�O�A�z��Y_�\WU����3[�=��y�y~�i<7U�d�7����u+���A�#��<~��U�`N��.x��%�|I ��#��Y��}7̕��X�=�-�$��g[���� ��\���^��� fg�����Ǧӻ�6"�x�{��hPmԱrI' O+�����F��m�kQ�Y^�c:������{���9���2jiiCX�1n�0m�A{KSX��}zo
����� ��h詙mg?�� sq��5I��{Xm���4�7#�ҐO�u<���2 `��g�Ygɱ[;s�`�S�"j_Y��E���Ǽ�/_mV� �D�Z��I�|�a�砀J�l7���2�����o^a0�ܞz�n�m����P�9 J�� ,Ń8�@Wi�?[$)�9�%sӉ���s������XFT�v�@�H��j��s�c��t.~�_���!�}\{Bm'nT�;�ǩ�����n���/q=%1���?ibvW#n��CK�zѶ�s�s��='_J��*8�y���m(�HF$��Xx���-O{w��5�U�T�Ў�kO��ݗ��Y��=�Nqբ3z�b����f�a�)��/ �U���G�1EIS�/zWǩOC5yĝ��Nzj�9�;�ɍy�����F	�L4`4��L��� ��I��z/,@3j��!��6Ua� �h%Jj�q�l6��������n���(5�����Z�5��Ure�Miu�@<�?	e���E��� �-B��G�A����Qv���=Gq��M�K�xf��u-��Y�z~��Pں���Nz�<>�0���2	� �Q��b�w�z�s��YU�l�n?Rf�SIF6Y�I�أ�9�X&���r�#[M[�6X�P���iR��ù��/�Ҋ������̷%L�CO���f�>3��=e\��G���*k.]��I��?��c!�I�=�֗N�&,z���PU��4�z1��L��Ӵbc�����3P����j4�j���@t�:�9�_�����J؎�1�)�N����1�@��Y���Qsg}�b�GSh���Q��k�X�����i��7V��U��-�^���v�.�<򃪜 g'W��m?�tN���������'j�%�b�yH6ZS^�f��r��CcQݍä
�י��Q��Y^��Nc��
�c��ꛭ%�k*�3��%=��:u�ӵi�Qz���^{�T7w��R�on�j��'$}� 7�p�hj-BJ����ciW[
���+���#�6�Q�Ohb��:Y��� �� $��̮��i9?y��zg��ՀpA� 3��Ƥ���	�y�����C.T�x--J�s�����V���jZ����F%1m)4��哸w�AmI��;Yx'��]X�Kh&�`���-u+�d�=2�U�[mCq����=�=
�k�s�Bj5Q����A��w���O�iӫ>��O�+[� �n�[���<��6�) ��0�#9���@�8��f��XA56�T�`pFH֟Yw�Z������)\䓐�T�C ���}�$����SQ�[0O�dh��`��������!�bu��WEH�T\��t��v��O�s:N�x����n�>O��J7��i^�'(�A����-# �n@*���˹]@?�6��PK�(��(v�)�ej����5GNjTڬy��*��<eX����2j��إ+v<�S���U�X��-I�lNޝ��f�*�޵�-�:�8���U�
�R3l .2&�� �m�j��񸞀	�˳��㙭>�ȷs�cs��#N��$Ƚg5|M���Z�<�mN�i���C��1��k]S�0A^� y����m��|1��kn+R���T�1��xG1}F�R�� ��YT[�=X�����okn��v�a��/7���J�L��꯰�Kyv�$����e�/��������SQ�G�kN}����;��Z
m�7��8�
����6�c�G6��%�lҔS��8�tG��'��z� �ɂ6�� �*��cy�ߞs)�� �,��Ԛ�Zى#'�������(��`����9�X7S[a�:�,�-��"���U �XP�%&���j�m��qv�J����%�Cb�H�>Ҽ�9��t4:t��xQ�f��s�gW�h/�k��Ժ�W�=3�ܣ�i�[�����#���:U� �m<�3S�^~���`RX�[���T�'G[�4�T9չ�P�I���`����z�51����t�߼º��3m���cs{Nw[r%��>�Z�G�������f�q�p�#r����Ԗ�J��$�N��U_M_� \�-j�+U>�D����g�EUt��dDm�9�� �����]��D���9#�[��%f��x"�{���V�E۝w�;L����8������9Q������l���gF ���gy�x�?q�WMj@�������O#��� �$fGqw�q���0�چW#e��&�U���p2:Ɉ��� 60�h��f��֡� s�oS��[��[��u�l��q������
��]����3pk�Oy�-�Q�t>��n��}N �ѽm��Xzpd��w��l���0�8����ᵺ]p���!pgL86 OA�`ή����WyK��T�i����r�;�cZMh�R����a9Z��iبg�� �,�p�W��NfO�y|���)����-,p��v� h27�ɍ��i�4���l�a���j�	S�Q-�,sБ�̤���tj�*���*��?O̳j����>��A\��#��*�.ܪ,��鈣�U �B=X�(�� L��T�v9����K�u���b�l�Vy�zi��Ь���j�OZl(�	���N�����ԥ���1/��jVD��FiAMIX�g0y��E4�k/�u�<���D_N)�����+��3�m�iSq
������v>��S� =�<���>#�Ik�h�W�r[$�:�-�}K�d����Z�a�z�:�-�)LKs �E�-j������}]kCy�ټ/�9����,���tz��j��y�9��g{iBA��c&L�Ǖ�_ڭ}�ǬX	��,>��T����Y�[Z����v�>�|CN]KUr�Q�i�^��>��=��׬gU����"Z��/_�&mDm��#�L^j��6y+�> I����D^�rğrfQ-��3����%A�@H�s��u\�����J�0���p`��Tc�M���~c��ɦ�*[�a]߶��̄0���.��\t ~���W���~f���M =�S"�0 v�G�S��/��wp����̭'���%��ӣ�K/��N1�{�) s��ZgWP���Af�WgPl��ܠ�J�g3�S:{l8�h�_�O`:�L�Y� ��91�P�31?i��x�uX�@6>{t����T��b�<1e�+Q�4؞Z� �[�{Nn����n�� ��]nձ+�g?;��}_���k=W*��9\�89�	mjL���~Q�1o�q��Y������m���1�G?�5	G��:g�I'��5���(
&C��׌0��J�7 ��隍@����K���������P�d��;��o��>��mŰ=��
�`�cM�R���n���$�0��66��Va�{�}�Z�#$��KO�<��}��T�JjkP�9#Iⷶ�+���hP8")�`պ�s�~#t��+� �>��4z"�s0�\8 �g��x����r�q��5���^�Cn�ә�(c�q�j��3�!8sY�e���Ծ��o�3�.g+U�1�������i��V��s�89�dq��z�M���<��� Y3��1�[�1�M#�p��I��TkS�k�6��`"�R!iRw�!��P�oaY�X�'�%��0r�<�W�ѵ s`�*zMC	������kZ\�j�I�G�����(���^��HMv����+��c�z�k�s4+�]O�j��O1�J��݁4�K����.�7���}HoM!���S��R͙�mT�
~ +����$0�&��h.%�%���a���bl�(��Y�[�!���Nn%[�=�3"�k�yT�]��Q.'�X.��\��#���,L����������О�-�i"�w�q� ��>�о�Q��������!bA=��[�=�ļ5B�*P}L7|�����Ѿ�7xM%Etj�q� �o_4V!�`����f�ӷL�qkaZ��s�kQ��5���K�W�r5Y'���1�!��"���7�GS9��c][��}�_KrդauXjx>���Z�nUֶ�N����
��~"�( ���6���7��j����+���8���x�+�	*�� ���~��E�puB��΂��3|��j�*�� ��wѶ��o������kn��T��ң��XZ*���$c��5`�jns�ߣ9��R����v���Zb�+�}X�:�u�f-�t��k�>�}%� ��y�q��U�|Ы�:��TD[�gw��S�j��mk�L�q�*�W�OJ�T�v���+Q�n���*S�Rű���-
l �
j��̕�#�A�Ʉ5n�r�M-�[;��8�=�d���d�gyu�8ʆ�2�y��@O_i���m�R-�ŋ���_�iڇÀ2210�Zl ���Q ( ���z�K${s 93[$р}������As2@Xh$=��ܡ�1�#@^�N��;Aa��u��d�9� �j�4����s�=`��L��I$�Ԩj���
��AlN���X�:�w�B�~Ӥ~i~7��r�B� �}���&\%a�r�~�I�d�A���s�5>��b%̖�;�V���
܏W��T�<��ُIȋ菜+�7.���c:��ն�©�
�g������	�ʺo��a��)�@��[w|Ɣ��8>�{�Ֆ�$�T-Y����������2K:�Nn����6��Ξ�Ҥ���e[�m��bl`���=gUB�����f��}EU��}F7��%`�<J� �L�lT���2���S��ὢ~!}���k�#⃥z]F��_G��n��Z�/զ��,�XpXv�]Of�ԍ�3׻G��(�n#Wj�!�?��kB��8ߎ�J��c)z�a��s�kj{���h�=�?M[�7�=����[��/\�P8 �׷-��{���T�O�j?�����	�d��kK U�4'�i�Q���)�SL����{�y�</�\i����i���s3nE�^I|OSVj�Cc��J[7���Oi�?�|"��~2���@p:���'�N޹vg9m[0[�F�,Ӓ��-F�Ͱ�ī�����j��;0:�9�;�oP�` ����5yG:�.Q���+��j��xm���B�mzs��?�Qə��'�
rW'�2E�Cm+��p��
\5��^y�Θ{� �`����W<�s�bb�8�u+�Uo#'v6�(�o��|���U��<˫J�5��Ɨ� 	f��u��gHxN�R�#�CL�dʘ�bmG�:�©�M���QUG�v~����Rl�8f<ɻ{�ēM�w�n>�fmB��8�a.DP��o���$ ;�L���#:=+j��Aձ�wM�wi�5��H=:� ��0��CMn��[-$�e�Ă�����r�0w5�������A��j�@�(��K��2� ��.�r=$�&5ٻ򱁊�e�;p�9>��� �}5��� 6a�ԫH%�`�Z۵*k�LOs�&���8e8#ۼ�0Z�q��w|� l���7:�T���@��s����*��Q��}�۹�ߕ8�f8us�`t��m�
|�rXp=���v),R���mղ�Wn8��ַ�Nv��%S:'
,Fc��n�:���6��}l嶂[�wA���j\��,%B��0�1��ȨW�Q�ӡ�����ᶰ`=>�.�\�>��R�\�D�'�k���!��3��;^�k1�m�?a��fo^���
��|��9A�0>�z��o-���X���Ȝ/��UVK;�8	���zo ��j@ ��ϼ�KXT���;����MU�Z�D {N�i���~�Y��Q�j�
X�\�i�4��Z۪U���I9�O����7�i��j���0 �"L>�wU��N�=q��c��}0z���U� � �=��U�n��{��p?N�wN��?Yv��5UYw�5
?�zs�����bTrw`��8���L?�p��'ӌ�F;N]�SJS.s�:��~j������;��{�����à���F��c�)���1.�㨃�u24n��nXD��4���jb]��˯��s9���bL�Lɪ©�m$n�LŚ{ju#���iP)�J��e���d9�;-� �R��0`l����;O̺���$�X�a�Mb�ǿh,`��&���I�R�=��2���ne�hɓ2��{wԹ�Hc��������( H��`�#���ռ"�d��o�G�a��.���8�?^�f���G��!(�����(�lL�`L����G�F>hDB+P@9~ave1��Qʹ8l�=�*�]����s�XYSӒ	��WS![����d5UB�lpx'h�!�C�� ��R��^y1��&�B��z�� N�P��O?��<	�Ѻ�>O�$��~����.��=����lq�su���&5��h��V�� �Q�N�]%zt�����2��y�����:�5>(�?���q��?�;�KbI��g��&���c+���I
���ָZ��/$�L���M2M���-<�a��Z�;�R '���sd�f6��WƵ���l��j}�q<��U�/w��� n�N=ۿ�'M��mqڊ/������~�#�ѽj̨{����s�{�o�a�S��z��;[��cU��gB�.�XI���Nv�Mn��p@=��c3bK�����Q^
�"�8-��>c��B}�uQb��Xls0���X`3 \s�(㯼$��Vx���l�2�t�_i:L�}������f|�vܸW�S3�bYR�K]YG �����u�`���b;D�F�ʷ�}本ǫ2��҉�r\��&L��4&3��05�3(I�a��ۿi���&�܈Qb�t�u��`�	 7�<�TL��b]([ʰ%��?�"�eO�;ֿP���,�]~��s�NT�^�z;�Zk.� ���a��� 0�.�u5oQ�q���Q�m]v������s�c!��������7L�#��w>�����N2;A�l�X2�n\O7���9����M�\��{2�~f7��	oVs>w=�s��Ӟ �j9��{p����wN}�o��K��~K?�����V  &�O@���99�#������뙟lu�N�9~;n��F��U}GuQ�=���D#<8Z�+�+I�w���O�-���v���Ӻ���GR�nV�q9��k
�2x'�}U�4�,�} �{O���^�P��l�1���V����D��zv �U2��ɹ�o��� �z�ĦK�ȥ|��gi<��;��x,w�Ű��M׬e>�g�9��ڲHi�S��V+c�hh,�7�k8� ��iGP�6q}���OF��X��f����)�H����Av�X�X@��؆������k�2��vTM��Ys��!39�fN`Y2��+�)�Y9�S7�f[�r�2�(���d��q��=�uo�ǧy���x��j�c 1�g�����M�]����{�UXr@�jt�%b�9'��+��G%����X�xPU��=I&9���������Og��M��,P���=�xmC7�j����c�� �s7i��u�yQ��8��~����*U��а[Pu�g>����m6W��>y�/��� ����L"�&w����N>O��>�7�}�Z����f���= a��7�LX哎0'�l�o���r�
��T��\H��"�Y��3T���Ps�y>_��ռf�݋��z}�H@��
i70���|��(� >[����7�s�=<�'\���W@P}M��m(.�����Mֵ^�rd}?hޑ�W��?��3frr��'�����(��Y�]c$��K�k+�������+⺟p��NV���>�v�X��搾��=��ğ�`� oy{@>�L��eT�� yJ��L�9<� J��]Dc[�I�U�p���b9Ț~ݥ��>�q�R>D"���Q�+�R�v�X��{B}e��3$�FW_�݈�C�y�q�h0Ħ�Ċ�����!<�}�礁��t�J��?�`��8�i�U�ܬX��A����ţ2e�d�2��0,��K7�D�$��*h�FK�:>��Uv�`B��� �͸�k~�{���J�=�u�Ea��Z�;���'ai s�Y�v�� k������U��QQ��݀���e�6S��|���;IyW�5�]c���,w)8���n5�?I�#���5�#0��;N�{	�����a�Ȏ�r�E��� d��D�=���~���~2U�ys�`��?��"V�l�<��O����� 	���?'���|�pE4J�z�q�!��gWS���{�9�-y�� ��� I~n��0 ��.Zik���	��x��ӭ`�m��OW�8�ʓ��b��1ɝ�9P]�d�9Z*�6��D�k������O��G3��|�}B�+m�'��/N�ҽ�ɜm]_�}�'#9=�r���UI�>#��v��P���3U缼��x���zܣ�V���̎bT���@����!t�Z�ҨT}�I�0 �Jnٚq���7�@��6�� � �u���w�x$�=�\g+��Ʃ�6�2=��2�đ�iRT�vB fN�����I��
1+�v̰H`�2���7�Y��x�$�$��,L�L�@�̆MfbQ�!P��Z-����"-~�U�
Y��TR�D8g�}�ͫ�A�E�����شߎ��O����i@a���>U]�J�y���f�@1V��?�9_����� ��y��:�h��� P��i�W�S�?]7'�SF �*�u����g��V�z��aК��:�-�l��f=��fqך�W���Q`O7ͫ��K(�q�80̼+�3�a�6g4_����pfc=��6�q�g���i�ƍs�g]p�S� ��'�/����XJ���||�%b�.s9�v�����5зT֧�FV��ݡ�z0�3Ͽ��N��ϴ�ԋZ�Q�Β9��H�UF ����%��w
	&%n�z��E��%�	�Wh�ծ��V��E� Ѽ/H��S#� ;�|n�,(&���_��R��|��1:�/]r�|�WJ�g�"�G�+8/fd�{�[�b�ssӬ\�2��6�&�<�!�2&�H��D��n:{C�n\�p��`y��p`�&	��K���y{� �}'�,�<�FAח�A&'��A� �2U�G9�4zAX�xQ�b��<��j���*NriP}؛0�W��I��g0�]��q����,��9�=�ꑙ��I�2X6<7(��Q�dwZԳ�Ŏ�j��>_��|��_]�T�av�?xU��>��>ß��it��k����h���`a3��>/�q��}eW�y��Ø�s7��?��\u�M>O�'<Ϡt���.���&7�1eZU4�H�Ij,P>���S�-����v�gP��� ዮ������g[=�� U�~�?#1]W�ԿF�?l	��q�'��m��9���x���6�'۴{O��Ӕ�\��2�:X��1�8����mu.2����'����i�67`�?�I�j��$���m>�ʑ�F&�����Ժ�K�V�S��� �ju��65��+7_��,=����A̯%�˳�_/!�R:�!-�/|	��VI�Ɇ]M.B�X��1�ۮP} �� N��*�Y��.ʗ�=��.����_�f�R�-��$�����A�W$h}=6^	�npyQ��&_����Q�k�FA�F�ԙ�	s�?�	֭r:K&�s쬨���v-�H�s�r9�R���Z�����I�2��nA�`�����a��\e�_�!T�Xf`�{7�"wr�S�fM�2��c�_c�wJ�{9"@��݇X�-�	>ٛaa! 7�Ns3���f~ZԷ�B�ܘ��5�0�lg���vS�(��Vllt��K�<��n_����jz���2��2�礭�
+`0u����.pD˻m�`�k���ߖ��ƻ��� :��?�����F�i��7h�M`��ߤ��o�Ӹ�y����ǧ����TK
 �y�E��?rbڏ�?bB�|k˟��1�<`Nn�Ĵ��>����'��Q���No��>N��xqԹ�X��C�� ����'Q誸[�U �7ED��US�������08�����z?�v
d�9�g��>��U����=���*N���x��É�����IcZ���a�0��Ӂ� ���˧�7���P��k�a�L�]�CaS��䜙ȻYm�Z�$��K�������wy��`�8`�T�u��dĲc���d�F%J�f��|v���i��9$���n4^�@q�㬨=N��J�|����㧴^X1}�㫣��"�Bȧ�;N������=V���*X�G8��:�����̓c[���ss�]~v��3����,��v�� ��צv�aq%~`��K�{b.X��2Ek�>���P��?i��c� #>�0��Ki?i��Ef\�mo=���+���)FFse��L��p��P��t� ��ҁ�V�E 陜mM��(�xe�#��S�c�#0$FzA� F!s����\�d�c2�n��5�!�y<D�v�I*�(�H�}k����pd�K���X���I'7Dg�<�O��5�ǹ�x��<MZ��\�d�	���^���G`�X|��' u'���Y��L����� ����)��~��ÿ��w� �?��4��@��z^�����=d�R��N�f.��r͏�����d�*X8��0]���Ġ�dA����U����]��&pa ��$�re@�%�!^efTfd�Q$�H\� w������GL��pgF�B��1�B�� �Ĥ^s "�X &�D�ۆ% �"@�� "^0��EP��8��%*��ɔ	�(��� |���&<�^��f�3=U��V��2EV��z��3�v�^�R�H��_�X��+���.�oa�Ȱ�bǩ�j�H�i���KOPM���Xs�����}��� �ׅ���l����Y$�	 �s��f�0�[@#T3�G�	����eq5ֹ�D�4_+�3$*fI$�"H8<��$$ �H�TnI�5��k��c��x��:��%���\
�^3�TE�DMc�DN�W�Ry�"@������@!�f.֑�2ыv��"h&g��̊�ɜ�����K�2<��q2G<K=d3i>K�垳�� �~'/a/�9�&:k���m�/n�u �ZzEI��z�MI�h:��/���3�i[+e',���yV��K=%L���3C�e5c�.��������"0�D��#��2�GҘ=�&��L�$��0q�f�����P$�IJ�H#��l66�0f$���I I$����
�'i�&px�=,ծ,}�bQߔf����
>�+ I�df�=&
�J`�]lCK�`�_��9Ķ���1�A���i�"��%G�Ɇ�E80��Rd`Z�1y��	A@9�����Μ��ŮR���&��ֶynpLu>��T����A�a��V5c��fB��0g:�m\��&�f^�<��U%���� ����0 Q;����&>aIVB5��36	��V���%���2Kğ9�T�LrrNI��$�@�I$	$�@�I//��2��2���f�YRI�e� �\㠃 ��Wt`®GY�1������� 2���KX���a�&2y0d�'�a�V �Rsɐ�&v���3�X!^ ]q2�" 5k�� �2�A���?U�&��(�Ox��=Ϲ�?�/��L�����*��1�Iab��4�wK�dV�9�ɮkX�0y�Ĵ-� ȅ�Nk��b�+cqR
�&�i`��f@����B� ��.��'0��&DԈ���8�c�m���Y��=�2d��[l*{�|Y2�8����Mm��� d��T��R	-�p ��*�I^eI$�%�� �e@��(u� �%���$�35��C�!8�Xd�$ ��V9�]$�%�H3����bZ��bhH�^��d	 �Jf���<KS�
��`��f`�`SȜx�8h w=:M��#�W�s�+�e�q��*:{@:�`��T��ŋ)@+)��7�'��՜��a�]KU�:��1p�^��5��G�.�y���6G<��*_-�	�2Ü.336Wh�H+$�$VfFJ�Y$�2����@�QR����HI%�$��{�K̩p  �K�OȚ*�:��`�Eu�	��0�\�n���A�̘_4	�2Lo'���̢e&x�2�%%�o���*s!2�Ҟ 	�V<B�q�2pe��0�<�09����ND	(e1�I[��&A�hJ3+l�Fed+}o�'#�s�_�3\bK�`:"�#�FH�P���L'1
�����l��33;b�%�(�Q6*c��N��:�5� �ؓ��6�^�,[ ����e�������yP$�II$�Ē�X��{� ����O������T�����Y�+�]�3�M����oh#�-gɟ/� �:���c~�L�!��v���X�� 