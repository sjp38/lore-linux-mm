Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id DC5436B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 10:32:12 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so97925954wib.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 07:32:12 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id na9si17239624wic.65.2015.03.24.07.32.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 07:32:11 -0700 (PDT)
Message-ID: <55117565.6080002@nod.at>
Date: Tue, 24 Mar 2015 15:32:05 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at> <m2twxacw13.wl@sfc.wide.ad.jp>
In-Reply-To: <m2twxacw13.wl@sfc.wide.ad.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, rusty@rustcorp.com.au, mathieu.lacage@gmail.com

Am 24.03.2015 um 15:25 schrieb Hajime Tazaki:
> At Tue, 24 Mar 2015 14:21:49 +0100,
> Richard Weinberger wrote:
>>
>> Am 24.03.2015 um 14:10 schrieb Hajime Tazaki:
>>  > == More information ==
>>>
>>> The crucial difference between UML (user-mode linux) and this approach
>>> is that we allow multiple network stack instances to co-exist within a
>>> single process with dlmopen(3) like linking for easy debugging.
>>
>> Is this the only difference?
>> We already have arch/um, why do you need arch/lib/ then?
>> My point is, can't you merge your arch/lib into the existing arch/um stuff?
>> From a very rough look your arch/lib seems like a micro UML.
> 
> I understand your point.
> but ptrace(2) based system call interception used by UML
> makes it depend on the host OS (i.e., linux kernel), while
> LibOS uses symbol hijacking with weak alias and LD_PRELOAD.
> 
> we're really thinking to run this library on other
> POSIX-like hosts (e.g., osx) though it's not coming yet.

Yeah, but this does not mean that arch/um and arch/lib can't coexist in arch/um.
Maybe you can add a "library operation mode" to UML.
I'll happily help you in that area.

>> BTW: There was already an idea for having UML as regular library.
>> See: http://user-mode-linux.sourceforge.net/old/projects.html
>> "UML as a normal userspace library"
> 
> thanks, it's new information for me.
> were there any trial on this idea ?

IIRC Jeff (the original author of UML) wanted to create a special linker script
such that you can build UML as shared object.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
