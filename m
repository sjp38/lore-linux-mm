Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2776B6B029E
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 17:51:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 79so77006553wmy.6
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 14:51:53 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xy10si32205351wjb.253.2016.10.31.14.51.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 31 Oct 2016 14:51:52 -0700 (PDT)
Subject: Re: More OOM problems
References: <eafb59b5-0a2b-0e28-ca79-f044470a2851@Quantum.com>
 <20160930214448.GB28379@dhcp22.suse.cz>
 <982671bd-5733-0cd5-c15d-112648ff14c5@Quantum.com>
 <20161011064426.GA31996@dhcp22.suse.cz>
 <c71036ae-73db-f05a-fd14-fe2de44515b9@suse.cz>
 <20161030041723.GA4767@hostway.ca>
 <cda7adea-6ba0-c2d1-baf0-bae388950360@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d7d67c89-6672-5cec-bba2-393ddb693f78@suse.cz>
Date: Mon, 31 Oct 2016 22:51:40 +0100
MIME-Version: 1.0
In-Reply-To: <cda7adea-6ba0-c2d1-baf0-bae388950360@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Kirby <sim@hostway.ca>
Cc: Michal Hocko <mhocko@suse.cz>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On 10/31/2016 10:41 PM, Vlastimil Babka wrote:
> In any case, it's still bad for 4.8 then.
> Can you send /proc/vmstat from the system with an uptime that already
> experienced at least one such oom?

Oh, and it might make sense to try the patch at the end of this e-mail:

https://marc.info/?l=linux-mm&m=147423605024993

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
