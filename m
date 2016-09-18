Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id B27C06B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 17:13:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k12so109149177lfb.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 14:13:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 204si15786092wmk.102.2016.09.18.14.13.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 14:13:58 -0700 (PDT)
Subject: Re: More OOM problems
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
 <CA+55aFy0o7B1eLMKaM37dK9PKfKCuyJKxsqK=G+Eno18dPW-CQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5bd50aca-99ca-8ea7-6008-5f83494c84fd@suse.cz>
Date: Sun, 18 Sep 2016 23:13:36 +0200
MIME-Version: 1.0
In-Reply-To: <CA+55aFy0o7B1eLMKaM37dK9PKfKCuyJKxsqK=G+Eno18dPW-CQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 09/18/2016 10:58 PM, Linus Torvalds wrote:
> On Sun, Sep 18, 2016 at 1:26 PM, Lorenzo Stoakes <lstoakes@gmail.com> wrote:
>>
>> I encountered this even after applying the patch discussed in the
>> original thread at https://lkml.org/lkml/2016/8/22/184.  It's not easily
>> reproducible but it is happening enough that I could probably check some
>> specific state when it next occurs or test out a patch to see if it
>> stops it if that'd be useful.
> 
> Since you can at least try to recreate it, how about the series in -mm
> by Vlastimil? The series was called "reintroduce compaction feedback
> for OOM decisions", and is in -mm right now:
> 
>   Vlastimil Babka (4):
>     Revert "mm, oom: prevent premature OOM killer invocation for high
> order request"
>     mm, compaction: more reliably increase direct compaction priority
>     mm, compaction: restrict full priority to non-costly orders
>     mm, compaction: make full priority ignore pageblock suitability
> 
> I'm not sure if Andrew has any other ones pending that are relevant to oom.

The 4 patches above had more as prerequisities already in -mm. So one
way to test is the whole tree:
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
tag mmotm-2016-09-14-16-49

or just a recent -next.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
