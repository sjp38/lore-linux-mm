Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D02EF280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 02:12:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 21so136320340pfy.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:12:33 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id c6si12680382pfj.136.2016.09.28.23.12.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 23:12:33 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id qn7so24346385pac.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 23:12:33 -0700 (PDT)
Date: Wed, 28 Sep 2016 23:12:29 -0700
From: Raymond Jennings <shentino@gmail.com>
Subject: Re: More OOM problems (sorry fro the mail bomb)
Message-ID: <20160928231229.55d767c1@metalhead.dragonrealms>
In-Reply-To: <20160921000458.15fdd159@metalhead.dragonrealms>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
	<20160921000458.15fdd159@metalhead.dragonrealms>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Wed, 21 Sep 2016 00:04:58 -0700
Raymond Jennings <shentino@gmail.com> wrote:

I would like to apologize to everyone for the mailbombing.  Something
went screwy with my email client and I had to bitchslap my installation
when I saw my gmail box full of half-composed messages being sent out.

For the curious, by the by, how does kcompactd work?  Does it just get
run on request or is it a continuous background process akin to
khugepaged?  Is there a way to keep it running in the background
defragmenting on a continuous trickle basis?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
