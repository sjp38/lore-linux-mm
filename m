Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 04E206B022C
	for <linux-mm@kvack.org>; Thu, 20 May 2010 01:39:10 -0400 (EDT)
MIME-Version: 1.0
Date: Thu, 20 May 2010 09:39:07 +0200
From: kernel <kernel@tauceti.net>
Subject: Re: [Bugme-new] [Bug 15709] New: swapper page allocation failure
In-Reply-To: <1273785234.22932.14.camel@localhost.localdomain>
References: <4BC43097.3060000@tauceti.net> <4BCC52B9.8070200@tauceti.net> <20100419131718.GB16918@redhat.com> <dbf86fc1c370496138b3a74a3c74ec18@tauceti.net> <20100421094249.GC30855@redhat.com> <c638ec9fdee2954ec5a7a2bd405aa2ba@tauceti.net> <20100422100304.GC30532@redhat.com> <4BD12F9C.30802@tauceti.net> <20100425091759.GA9993@redhat.com> <4BD4A917.70702@tauceti.net> <20100425204916.GA12686@redhat.com> <1272284154.4252.34.camel@localhost.localdomain> <4BD5F6C5.8080605@tauceti.net> <1272315854.8984.125.camel@localhost.localdomain> <4BD61147.40709@tauceti.net> <1272324536.16814.45.camel@localhost.localdomain> <4BD76B81.2070606@tauceti.net> <be8a0f012ebb2ae02522998591e6f1a5@tauceti.net> <4BE33259.3000609@tauceti.net> <1273181438.22155.26.camel@localhost.localdomain> <4BEC6A5D.5070304@tauceti.net> <1273785234.22932.14.camel@localhost.localdomain>
Message-ID: <a133ef4ed022a00afd40b505719ae3d2@tauceti.net>
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: mst@redhat.com, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Mel Gorman <mel@csn.ul.ie>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Trond,

have you had some time to download the wireshark dump?

Thanks!
Robert

On Thu, 13 May 2010 17:13:54 -0400, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2010-05-13 at 23:08 +0200, Robert Wimmer wrote: 
>> Finally I've had some time to do the next test.
>> Here is a wireshark dump (~750 MByte):
>> http://213.252.12.93/2.6.34-rc5.cap.gz
>> 
>> dmesg output after page allocation failure:
>> https://bugzilla.kernel.org/attachment.cgi?id=26371
>> 
>> stack trace before page allocation failure:
>> https://bugzilla.kernel.org/attachment.cgi?id=26369
>> 
>> stack trace after page allocation failure:
>> https://bugzilla.kernel.org/attachment.cgi?id=26370
>> 
>> I hope the wireshark dump is not to big to download.
>> It was created with
>> tshark -f "tcp port 2049" -i eth0 -w 2.6.34-rc5.cap
>> 
>> Thanks!
>> Robert
> 
> Hi Robert,
> 
> I tried the above wireshark dump URL, but it appears to point to an
> empty file.
> 
> Cheers
>   Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
