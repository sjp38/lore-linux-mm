Message-ID: <3764DA04.99899B05@switchboard.ericsson.se>
Date: Mon, 14 Jun 1999 12:31:32 +0200
From: Marcus Sundberg <erammsu@kieraypc01.p.y.ki.era.ericsson.se>
MIME-Version: 1.0
Subject: Re: I do not know what the code means.
References: <3765243A.8926786B@asdc.com.cn>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ZhangWeiXue@asdc.com.cn
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ZhangWeiXue wrote:
> 
> Dear all,
> 
> The following code is cut from the head.s, I do not know exactly what it
> do?
> If you can explain the meaning of " .long 0x00102007 " and " .fill
> __USER_PGD_PTRS-1,4,0" for me,
> I will appreciate deeply.
> Best regards.
> 
> /*
>  * This is initialized to create a identity-mapping at 0-4M (for bootup
>  * purposes) and another mapping of the 0-4M area at virtual address
>  * PAGE_OFFSET.
>  */
> .org 0x1000
> ENTRY(swapper_pg_dir)
>  .long 0x00102007
>  .fill __USER_PGD_PTRS-1,4,0
>  /* default: 767 entries */
>  .long 0x00102007
>  /* default: 255 entries */
>  .fill __KERNEL_PGD_PTRS-1,4,0

Hi,

There are zero files named 'head.s' and 12 files names 'head.S' in
the Linux kernel sources, so telling which file you are referring
to would have been good.
However this is not an MM or even Linux related question. You will
find the answer in the "Pseudo Ops" section of the GNU Assembler
manual ('info as').

//Marcus
-- 
-------------------------------+------------------------------------
        Marcus Sundberg        | http://www.stacken.kth.se/~mackan/
 Royal Institute of Technology |       Phone: +46 707 295404
       Stockholm, Sweden       |   E-Mail: mackan@stacken.kth.se
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
