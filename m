Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 84ED86B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 02:05:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so14716079wmf.3
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 23:05:23 -0800 (PST)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id n13si11620338wmg.164.2016.12.04.23.05.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Dec 2016 23:05:22 -0800 (PST)
Received: by mail-wm0-f44.google.com with SMTP id a197so82082280wmd.0
        for <linux-mm@kvack.org>; Sun, 04 Dec 2016 23:05:22 -0800 (PST)
Date: Mon, 5 Dec 2016 08:05:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Silly question about dethrottling
Message-ID: <20161205070519.GA30765@dhcp22.suse.cz>
References: <CAGDaZ_r3-DxOEsGdE2y1UsS_-=UR-Qc0CsouGtcCgoXY3kVotQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_r3-DxOEsGdE2y1UsS_-=UR-Qc0CsouGtcCgoXY3kVotQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>

On Sun 04-12-16 13:56:54, Raymond Jennings wrote:
> I have an application that is generating HUGE amounts of dirty data.
> Multiple GiB worth, and I'd like to allow it to fill at least half of my
> RAM.

Could you be more specific why and what kind of problem you are trying
to solve?

> I already have /proc/sys/vm/dirty_ratio pegged at 80 and the background one
> pegged at 50.  RAM is 32GiB.

There is also dirty_bytes alternative which is an absolute numer.

> it appears to be butting heads with clean memory.  How do I tell my system
> to prefer using RAM to soak up writes instead of caching?

I am not sure I understand. Could you be more specific about what is the
actual problem? Is it possible that your dirty data is already being
flushed and that is wy you see a clean cache?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
