Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7576B003D
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 19:54:39 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n2INsZ76009023
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 23:54:35 GMT
Received: from wf-out-1314.google.com (wfg24.prod.google.com [10.142.7.24])
	by spaceape9.eur.corp.google.com with ESMTP id n2INsLQl016256
	for <linux-mm@kvack.org>; Wed, 18 Mar 2009 16:54:34 -0700
Received: by wf-out-1314.google.com with SMTP id 24so342647wfg.15
        for <linux-mm@kvack.org>; Wed, 18 Mar 2009 16:54:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LFD.2.00.0903181634500.17240@localhost.localdomain>
References: <604427e00903181244w360c5519k9179d5c3e5cd6ab3@mail.gmail.com>
	 <20090318151157.85109100.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.0903181522570.3082@localhost.localdomain>
	 <604427e00903181618t66020557kda533d37f51d7e7d@mail.gmail.com>
	 <alpine.LFD.2.00.0903181634500.17240@localhost.localdomain>
Date: Wed, 18 Mar 2009 16:54:33 -0700
Message-ID: <604427e00903181654y308d57d8w2cb32eab831cf45a@mail.gmail.com>
Subject: Re: ftruncate-mmap: pages are lost after writing to mmaped file.
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, guichaz@gmail.com, Alex Khesin <alexk@google.com>, Mike Waychison <mikew@google.com>, Rohit Seth <rohitseth@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 18, 2009 at 4:36 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>
> On Wed, 18 Mar 2009, Ying Han wrote:
>> >
>> > Can you say what filesystem, and what mount-flags you use? Iirc, last time
>> > we had MAP_SHARED lost writes it was at least partly triggered by the
>> > filesystem doing its own flushing independently of the VM (ie ext3 with
>> > "data=journal", I think), so that kind of thing does tend to matter.
>>
>> /etc/fstab
>> "/dev/hda1 / ext2 defaults 1 0"
>
> Sadly, /etc/fstab is not necessarily accurate for the root filesystem. At
> least Fedora will ignore the flags in it.
>
> What does /proc/mounts say? That should be a more reliable indication of
> what the kernel actually does.

"/dev/root / ext2 rw,errors=continue 0 0"

>
> That said, I assume the ext2 part is accurate. Maybe that's why people
> haven't seen it - I guess most testing was done on ext3. It certainly was
> for me.
>
>> > Ying Han - since you're all set up for testing this and have reproduced it
>> > on multiple kernels, can you try it on a few more kernel versions? It
>> > would be interesting to both go further back in time (say 2.6.15-ish),
>> > _and_ check something like 2.6.21 which had the exact dirty accounting
>> > fix. Maybe it's not really an old bug - maybe we re-introduced a bug that
>> > was fixed for a while.
>>
>> I will give a try.
>
> Thanks,
>
>                Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
