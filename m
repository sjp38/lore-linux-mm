Received: from mail.intermedia.net ([207.5.44.129])
	by kvack.org (8.8.7/8.8.7) with SMTP id KAA07280
	for <linux-mm@kvack.org>; Fri, 30 Apr 1999 10:00:23 -0400
Received: from [212.184.137.63] by mail.colorfullife.com (NTMail 3.03.0017/1.abcr) with ESMTP id ra358063 for <linux-mm@kvack.org>; Fri, 30 Apr 1999 07:01:37 -0700
Message-ID: <003101be93da$75c98fd0$c80c17ac@clmsdev.local>
Reply-To: "Manfred Spraul" <masp0008@stud.uni-sb.de>
From: "Manfred Spraul" <manfreds@colorfullife.com>
Subject: Re: Hello
Date: Sat, 1 May 1999 15:56:46 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Stephen C. Tweedie <sct@redhat.com>
>NT's VLM support only gives you access to the high memory if you use a
>special API.  We plan on supporting clean access to all of physical
>memory quite transparently for Linux, without any such restrictions.
Do you plan that for 2.2 or 2.3?
Do you think that this will be backported to 2.2?
If not, then I'll write a quick and dirty shm modification which supports
more memory, and I'll disable swapping for that memory.

A note about VLM:
* VLM is a Microsoft invention for Windows NT on Alpha:
the user mode program is 64 bit, the kernel mostly 32 bit.
Pointers are sign extended by the processor.
A special kernel extension allows user mode processes to
map up to 28 GB memory into the middle of the memory space.
The rest of the OS knows nothing about this memory.
>From the MSDN Library:
>VLM is supported only on processors that directly support
> native 64-bit addressing. At present, these include the
> Compaq DIGITAL AlphaServer processors and specifically
> exclude the Intel 80286, 80386, 80486, Pentium, and
> Pentium II processors. 

* I read something on the Intel website about a kernel extension
which Intel wrote for the Pentium Processor.
If Linux supports more than 2 GB memory on 32 Bit processor,
then the implementation will be similar to that.

Do you have any details about PSE-36?
This seems to be a page table extention for the Xeon CPU's
AFAIK, this is not identical to PAE (available since PPro).
And: AFAIK, there are no chipsets which support > 4 GB
memory for PPro's, so there is no need to support PAE if PSE-36
is easier to implement.

Regards,
    Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
