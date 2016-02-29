Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 520BB6B0009
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 12:33:15 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id l68so73684135wml.0
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:33:15 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id b188si21320764wmh.99.2016.02.29.09.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 09:33:14 -0800 (PST)
Received: by mail-wm0-f45.google.com with SMTP id p65so1132751wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 09:33:14 -0800 (PST)
Date: Mon, 29 Feb 2016 18:33:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] writeback: move list_lock down into the for loop
Message-ID: <20160229173312.GK16930@dhcp22.suse.cz>
References: <1456505185-21566-1-git-send-email-yang.shi@linaro.org>
 <20160229150618.GA16939@dhcp22.suse.cz>
 <56D47F90.9050903@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D47F90.9050903@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: tj@kernel.org, jack@suse.cz, axboe@fb.com, fengguang.wu@intel.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Mon 29-02-16 09:27:44, Shi, Yang wrote:
> On 2/29/2016 7:06 AM, Michal Hocko wrote:
> >On Fri 26-02-16 08:46:25, Yang Shi wrote:
> >>The list_lock was moved outside the for loop by commit
> >>e8dfc30582995ae12454cda517b17d6294175b07 ("writeback: elevate queue_io()
> >>into wb_writeback())", however, the commit log says "No behavior change", so
> >>it sounds safe to have the list_lock acquired inside the for loop as it did
> >>before.
> >>Leave tracepoints outside the critical area since tracepoints already have
> >>preempt disabled.
> >
> >The patch says what but it completely misses the why part.
> 
> I'm just wondering the finer grained lock may reach a little better
> performance, i.e. more likely for preempt, lower latency.

If this is supposed to be a performance enhancement then some numbers
would definitely make it easier to get in. Or even an arguments to back
your theory. Basing your argument on 4+ years commit doesn't really seem
sound... Just to make it clear, I am not opposing the patch I just
stumbled over it and the changelog was just too terrible which made me
response.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
