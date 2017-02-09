Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE7B46B0387
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 14:40:12 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 67so9262284wrb.5
        for <linux-mm@kvack.org>; Thu, 09 Feb 2017 11:40:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k69si40279wmh.64.2017.02.09.11.40.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Feb 2017 11:40:11 -0800 (PST)
Date: Thu, 9 Feb 2017 20:40:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3 staging-next] oom: Add notification for oom_score_adj
Message-ID: <20170209194008.GD31906@dhcp22.suse.cz>
References: <84f5f88f-c528-4b48-5d1c-2cc1548da911@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84f5f88f-c528-4b48-5d1c-2cc1548da911@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sonymobile.com>
Cc: devel@driverdev.osuosl.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Riley Andrews <riandrews@android.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org

On Thu 09-02-17 14:21:49, peter enderborg wrote:
> This adds subscribtion for changes in oom_score_adj, this
> value is important to android systems.

Why? Who is user of this API?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
