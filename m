Message-ID: <39E5E469.2020304@SANgate.com>
Date: Thu, 12 Oct 2000 19:18:49 +0300
From: BenHanokh Gabriel <gabriel@SANgate.com>
MIME-Version: 1.0
Subject: mix-block size for raw_io ??
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi

i saw that the raw interface is using 1/2K blocks for io.
i understand that raw_io needs to support disk accesses in sector 
resolution, but why is it not possible to mix block sizes for the same 
device -> giving a much better performance using something like:
---------------------
left_bytes    = io_size % 4K
bytes            = io_size - left_bytes

call brw_kiovec(bytes)         // using_4K_blocks
call brw_kiovec(left_bytes) // using_1/2K_blocks
----------------------

the brw_kiovec() doesn't seems to remember block_size between calls  as 
it calculates everything based on the block_size passed as parameter.

is there any reason why we don't use mix-block-size ?

please CC me for answers

THX
/Gabriel BenHanokh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
