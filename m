Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9F412280251
	for <linux-mm@kvack.org>; Thu, 29 Sep 2016 03:03:26 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id b130so63336870wmc.2
        for <linux-mm@kvack.org>; Thu, 29 Sep 2016 00:03:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si13747879wmb.25.2016.09.29.00.03.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 29 Sep 2016 00:03:24 -0700 (PDT)
Subject: Re: More OOM problems (sorry fro the mail bomb)
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <20160921000458.15fdd159@metalhead.dragonrealms>
 <20160928231229.55d767c1@metalhead.dragonrealms>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f35c1c03-c1ef-e4fb-44c8-187b75180130@suse.cz>
Date: Thu, 29 Sep 2016 09:03:22 +0200
MIME-Version: 1.0
In-Reply-To: <20160928231229.55d767c1@metalhead.dragonrealms>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 09/29/2016 08:12 AM, Raymond Jennings wrote:
> On Wed, 21 Sep 2016 00:04:58 -0700
> Raymond Jennings <shentino@gmail.com> wrote:
>
> I would like to apologize to everyone for the mailbombing.  Something
> went screwy with my email client and I had to bitchslap my installation
> when I saw my gmail box full of half-composed messages being sent out.

FWIW, I apparently didn't receive any.

> For the curious, by the by, how does kcompactd work?  Does it just get
> run on request or is it a continuous background process akin to
> khugepaged?  Is there a way to keep it running in the background
> defragmenting on a continuous trickle basis?

Right now it gets run on request. Kswapd is woken up when watermarks get 
between "min" and "low" and when it finishes reclaim and it was a 
high-order request, it wakes up kcompactd, which compacts until page of 
given order is available. That mimics how it was before when kswapd did 
the compaction itself, but I know it's not ideal and plan to make 
kcompactd more proactive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
