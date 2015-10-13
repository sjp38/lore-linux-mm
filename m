Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2B96B0257
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 11:13:46 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so62724688wic.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 08:13:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ol8si5284563wic.74.2015.10.13.07.43.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 13 Oct 2015 07:43:38 -0700 (PDT)
Date: Tue, 13 Oct 2015 16:43:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Making per-cpu lists draining dependant on a flag
Message-ID: <20151013144335.GB31034@dhcp22.suse.cz>
References: <56179E4F.5010507@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56179E4F.5010507@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, Andrew Morton <akpm@linux-foundation.org>, Marian Marinov <mm@1h.com>, SiteGround Operations <operations@siteground.com>

On Fri 09-10-15 14:00:31, Nikolay Borisov wrote:
> Hello mm people,
> 
> 
> I want to ask you the following question which stemmed from analysing
> and chasing this particular deadlock:
> http://permalink.gmane.org/gmane.linux.kernel/2056730
> 
> To summarise it:
> 
> For simplicity I will use the following nomenclature:
> t1 - kworker/u96:0
> t2 - kworker/u98:39
> t3 - kworker/u98:7

Could you be more specific about the trace of all three parties?
I am not sure I am completely following your description. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
