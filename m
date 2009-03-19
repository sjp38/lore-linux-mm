Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 86EC86B003D
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 17:18:02 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n2JLHxJ1002745
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 21:17:59 GMT
Received: from rv-out-0708.google.com (rvbl33.prod.google.com [10.140.88.33])
	by wpaz21.hot.corp.google.com with ESMTP id n2JLHYgR005610
	for <linux-mm@kvack.org>; Thu, 19 Mar 2009 14:17:58 -0700
Received: by rv-out-0708.google.com with SMTP id l33so776585rvb.56
        for <linux-mm@kvack.org>; Thu, 19 Mar 2009 14:17:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0903191317220.3030@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	 <200903200248.22623.nickpiggin@yahoo.com.au>
	 <alpine.LFD.2.00.0903190902000.17240@localhost.localdomain>
	 <200903200334.55710.nickpiggin@yahoo.com.au>
	 <alpine.LFD.2.00.0903190948510.17240@localhost.localdomain>
	 <alpine.LFD.2.00.0903191317220.3030@localhost.localdomain>
Date: Thu, 19 Mar 2009 14:17:57 -0700
Message-ID: <604427e00903191417m2512f0dbl94163093cffce703@mail.gmail.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 19, 2009 at 1:21 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Thu, 19 Mar 2009, Linus Torvalds wrote:
>>
>> Ahh, so you re-created it? On ext2 only, or is it visible on ext3 as wel=
l?
>> I've not even tested - I assumed that I would have to boot into less
>> memory and downgrade my filesystem to ext2, which made me hope somebody
>> else would pick it up first ;)
>
> Oh, btw, can people who see this (Ying Han, Nick and apparently Jan)
> detail their configurations, please? In particular
>
> =A0- SMP? (CONFIG_SMP and how many cores do you have if so?)
"CONFIG_SMP=3Dy"
the testing machine i was using has 16 cores.

>
> =A0- PREEMPT (NONE/VOLUNTARY or full preempt?)
CONFIG_PREEMPT_NONE=3Dy
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_BKL=3Dy

>
> =A0- RCU (CLASSIC/TREE/PREEMPT?)
Not in my .config file.
>
> since those affect the kinds of races we can see a lot.
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
