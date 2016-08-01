Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 497216B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 02:16:30 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so68705830lfe.0
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 23:16:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id rv14si29890331wjb.235.2016.07.31.23.16.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 31 Jul 2016 23:16:28 -0700 (PDT)
Date: Mon, 1 Aug 2016 08:16:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160801061625.GA11623@dhcp22.suse.cz>
References: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8f3adcc-3607-1ef6-9ec5-82b2e125eef2@quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: linux-mm@kvack.org

[CC linux-mm]

On Sun 31-07-16 21:29:02, Ralf-Peter Rohbeck wrote:
> Hello,
> 
> I just noted that 4.7rc7 killed processes for no good reason apparently, on
> a system with plenty of memory free and plenty of swap space.

Have you seen a similar with 4.6? Can you reproduce this behavior?
 
> At the time I initialized some USB3 drives by overwriting them with zeroes
> so IO was constantly busy (sync never finished.) Not sure if that was the
> reason. Still looking.

Could you share your OOM report please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
