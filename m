From: "Abu M. Muttalib" <abum@aftek.com>
Subject: RE: Commenting out out_of_memory() function in __alloc_pages()
Date: Sun, 9 Jul 2006 11:41:22 +0530
Message-ID: <BKEKJNIHLJDCFGDBOHGMGEEJDCAA.abum@aftek.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
In-reply-to: <200607090018.45972.chase.venters@clientec.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chase Venters <chase.venters@clientec.com>
Cc: Robert Hancock <hancockr@shaw.ca>, kernelnewbies@nl.linux.org, linux-newbie@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

>>
>> I tried with the /proc/sys/vm/overcommit_memory=2 and the system refused
to
>> load the program altogether.
>>
>> In this scenario is making overcommit_memory=2 a good idea?
>
>(Good mailing list practices ask you not to top-post - that is, make your
>reply text follow the text you are replying other than appearing before it,
>as I demonstrate here:)
>
Hope this time round I am following the std practice. :-)
>
>Well, how much memory do you have? Does the application actually need more
>memory than your system can provide? If this is the case, there isn't going
>to be any fix except add more memory. Your choices are:
>
>1. Let the OOM killer sacrifice processes because you don't have enough
memory
>2. Disable VM overcommit so that the OOM killer doesn't get engaged
(rather,
>the application's attempt to grab the memory will fail)
>3. Add more memory, don't mess with the overcommit sysctl, and watch things
>work nicely :P

>Are you sure it's not a memory leak? Does the application work on a freshly
>booted system?

I have a total of 16 MB RAM. My main concern is that I was running the same
set of applications earlier on linux-2.4.19-rmk7-pxa1 and didn't get any out
of memory. I am running the same application and get the OOM, though the
appearance is not uniform, at times it comes on a freshly booted system and
at times it didn't come when the system is on overnight.... Why I am getting
here??? Is there any problem with linux-2.6.13?

I have tried to check the application for memory leak with no success. There
seems to be no memory leak.

>Thanks,
>Chase

Regards,
Abu.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
