Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA0076B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 02:27:18 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k12so114671043lfb.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 23:27:18 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id et1si24724140wjd.133.2016.09.18.23.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Sep 2016 23:27:14 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id l132so132928233wmf.0
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 23:27:12 -0700 (PDT)
Subject: Re: More OOM problems
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz>
 <CA+55aFx8qwCVZFa9VZTMMgzhn9qphsrOFYJVWtfHs9bAVEWhGw@mail.gmail.com>
From: Jiri Slaby <jslaby@suse.cz>
Message-ID: <824b0cb4-596f-b873-0609-68201f5622db@suse.cz>
Date: Mon, 19 Sep 2016 08:27:10 +0200
MIME-Version: 1.0
In-Reply-To: <CA+55aFx8qwCVZFa9VZTMMgzhn9qphsrOFYJVWtfHs9bAVEWhGw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>
Cc: Olaf Hering <olaf@aepfle.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Oleg Nesterov <oleg@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

On 09/18/2016, 11:18 PM, Linus Torvalds wrote:
> SLUB is marked default in our
> config files, and I think most distros follow that (I know Fedora
> does, didn't check others).

For the reference, all active SUSE kernels use SLAB.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
