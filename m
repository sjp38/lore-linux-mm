Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id LAA08520
	for <linux-mm@kvack.org>; Fri, 30 Apr 1999 11:25:42 -0400
Received: from [212.184.137.58] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id da358127 for <linux-mm@kvack.org>; Fri, 30 Apr 1999 08:27:01 -0700
Message-ID: <001801be93e6$ca0a0cd0$c80c17ac@clmsdev.local>
Reply-To: "Manfred Spraul" <masp0008@stud.uni-sb.de>
From: "Manfred Spraul" <manfreds@colorfullife.com>
Subject: Re: Hello
Date: Sat, 1 May 1999 17:25:01 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Manfred Spraul <masp0008@stud.uni-sb.de>, "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I wrote a few hour ago:
>Do you have any details about PSE-36?
I found the description about PSE-36, it's part of the addendum
to Volume 3 of the PII documentation.
(available from http://www.intel.com/design/pentiumii/manuals/)
In summary:
On PII Xeon processors, you can use 4 MB PTE's to map
physical memory from the complete 36 bit address space.
They use the formerly reserved bits in the middle of the PTE
for this. Everything else remains unchanged. Actually, PSE-36 is
always enabled on PII Xeon processors if you enable
the 4 MB page table entries.
The modification only applies to 4 MB pte's, PSE-36 does
not allow you to access high memory with 4 kb PTE's

Please ignore my post about Intel's NT device driver:
It's a simple hack, it allows you to use the remaining memory
as a ramdisk. 

Regards,
    Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
