Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 08DC26B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 05:57:02 -0400 (EDT)
MIME-Version: 1.0
Date: Wed, 02 Jun 2010 13:56:58 +0200
From: kernel <kernel@tauceti.net>
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
In-Reply-To: <4BFC2CB2.9050305@tauceti.net>
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net> <20100419131718.GB16918@redhat.com> <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net> <20100421094249.GC30855@redhat.com> <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net> <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net> <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net> <20100425204916.GA12686@redhat.com> <1272284154.4252.34.camel@localhost.localdomain> <4BD5F6C5.8080605@tauceti.net> <1272315854.8984.125.camel@localhost.localdomain> <4BD61147.40709@tauceti.net> <1272324536.16814.45.camel@localhost.localdomain> <4BD76B81.2070606@tauceti.net> <be8a0f012ebb2ae02522998591e6f1a5@tauceti.net> <4BE33259.3000609@tauceti.net> <1273181438.22155.26.camel@localhost.localdomain> <4BEC6A5D.5070304@tauceti.net> <1273785234.22932.14.camel@localhost.localdomain> <a133ef4ed022a00afd40b505719ae3d2@tauceti.net> <4BFC2CB2.9050305@tauceti.net>
Message-ID: <570793a158a0db68d623d424c38672bd@tauceti.net>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Robert Wimmer <kernel@tauceti.net>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, mst@redhat.com, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Trond,

currently it seems that the problem was 
fixed by accident... ;-) Since 2.6.34 is now
in Gentoo portage I thought I should give
it a try. Using my 2.6.35-r5 .config 
the 2.6.34 release is now working for 4 hours
(instead of 5-10 minutes before). Hmmm...
Hopefully it will run for some more hours
and days now. Since I've definitely changed
nothing besides the kernel it must have been
fixed (hopefully) in one of the 2.6.34-rc's.

If it's still running tomorrow I'll close
the bug.

Greetings
Robert

On Tue, 25 May 2010 22:01:54 +0200, Robert Wimmer <kernel@tauceti.net>
wrote:
> Hi Trond,
> 
> just a little reminder ;-)
> 
> Thanks!
> Robert
> 
> On 05/20/10 09:39, kernel@tauceti.net wrote:
>> Hi Trond,
>>
>> have you had some time to download the wireshark dump?
>>
>> Thanks!
>> Robert
>>
>> On Thu, 13 May 2010 17:13:54 -0400, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>   
>>> On Thu, 2010-05-13 at 23:08 +0200, Robert Wimmer wrote: 
>>>     
>>>> Finally I've had some time to do the next test.
>>>> Here is a wireshark dump (~750 MByte):
>>>> http://213.252.12.93/2.6.34-rc5.cap.gz
>>>>
>>>> dmesg output after page allocation failure:
>>>> https://bugzilla.kernel.org/attachment.cgi?id=26371
>>>>
>>>> stack trace before page allocation failure:
>>>> https://bugzilla.kernel.org/attachment.cgi?id=26369
>>>>
>>>> stack trace after page allocation failure:
>>>> https://bugzilla.kernel.org/attachment.cgi?id=26370
>>>>
>>>> I hope the wireshark dump is not to big to download.
>>>> It was created with
>>>> tshark -f "tcp port 2049" -i eth0 -w 2.6.34-rc5.cap
>>>>
>>>> Thanks!
>>>> Robert
>>>>       
>>> Hi Robert,
>>>
>>> I tried the above wireshark dump URL, but it appears to point to an
>>> empty file.
>>>
>>> Cheers
>>>   Trond
>>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
