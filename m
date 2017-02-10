Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CA5516B0038
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 05:27:35 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id 67so11667090wrb.5
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 02:27:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k91si1579113wrc.221.2017.02.10.02.27.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Feb 2017 02:27:34 -0800 (PST)
Date: Fri, 10 Feb 2017 11:27:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3 staging-next] android: Lowmemmorykiller task tree
Message-ID: <20170210102732.GB10054@dhcp22.suse.cz>
References: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <df828d70-3962-2e43-0512-1777a9842bb2@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

[I have only now see this cover - it answers some of the questions I've
 had to specific patches. It would be really great if you could use git
 send-email to post patch series - it just does the right thing(tm)]

On Thu 09-02-17 14:21:40, peter enderborg wrote:
> Lowmemorykiller efficiency problem and a solution.
> 
> Lowmemorykiller in android has a severe efficiency problem. The basic
> problem is that the registered shrinker gets called very often without
>  anything actually happening.

Which is an inherent problem because lkml doesn't belong to shrinkers
infrastructure.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
