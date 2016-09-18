Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6797F6B025E
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 17:34:42 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s64so109247789lfs.1
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 14:34:42 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id kg3si15579828wjb.37.2016.09.18.14.34.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Sep 2016 14:34:41 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id 133so12089432wmq.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 14:34:41 -0700 (PDT)
Date: Sun, 18 Sep 2016 22:34:38 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: More OOM problems
Message-ID: <20160918213438.GA3434@lucifer>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160918202614.GB31286@lucifer>
 <CA+55aFy0o7B1eLMKaM37dK9PKfKCuyJKxsqK=G+Eno18dPW-CQ@mail.gmail.com>
 <5bd50aca-99ca-8ea7-6008-5f83494c84fd@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5bd50aca-99ca-8ea7-6008-5f83494c84fd@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Sun, Sep 18, 2016 at 11:13:36PM +0200, Vlastimil Babka wrote:
>
> The 4 patches above had more as prerequisities already in -mm. So one
> way to test is the whole tree:
> git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git
> tag mmotm-2016-09-14-16-49
>
> or just a recent -next.
>

Thanks, I will try this out (probably using a recent -next.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
