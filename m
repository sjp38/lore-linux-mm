Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 347976B025E
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 11:33:04 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id gf1so2996626wjb.3
        for <linux-mm@kvack.org>; Wed, 11 Jan 2017 08:33:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w73si4804108wrb.0.2017.01.11.08.33.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Jan 2017 08:33:03 -0800 (PST)
Date: Wed, 11 Jan 2017 17:33:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: getting oom/stalls for ltp test cpuset01 with latest/4.9 kernel
Message-ID: <20170111163301.GI16365@dhcp22.suse.cz>
References: <CAFpQJXUq-JuEP=QPidy4p_=FN0rkH5Z-kfB4qBvsf6jMS87Edg@mail.gmail.com>
 <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <075075cc-3149-0df3-dd45-a81df1f1a506@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Ganapatrao Kulkarni <gpkulkarni@gmail.com>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 11-01-17 12:05:44, Vlastimil Babka wrote:
> On 01/11/2017 11:50 AM, Ganapatrao Kulkarni wrote:
> > Hi,
> > 
> > we are seeing OOM/stalls messages when we run ltp cpuset01(cpuset01 -I
> > 360) test for few minutes, even through the numa system has adequate
> > memory on both nodes.
> > 
> > this we have observed same on both arm64/thunderx numa and on x86 numa system!
> > 
> > using latest ltp from master branch version 20160920-197-gbc4d3db
> > and linux kernel version 4.9
> > 
> > is this known bug already?
> 
> Probably not.
> 
> Is it possible that cpuset limits the process to one node, and numa
> mempolicy to the other node?

No this shouldn't happen AFAICS. It is more likely that there is an
unrelated memory pressure happenning at the same time.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
