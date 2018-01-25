Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79DF7280245
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 04:37:27 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 62so4059399wrf.8
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 01:37:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n26si584575wmh.135.2018.01.25.01.37.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 01:37:26 -0800 (PST)
Date: Thu, 25 Jan 2018 10:37:24 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] few MM topics
Message-ID: <20180125093724.h3j6m3d4msblyhgy@quack2.suse.cz>
References: <20180124092649.GC21134@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180124092649.GC21134@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-nvme@lists.infradead.org, linux-fsdevel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>

Hi,

On Wed 24-01-18 10:26:49, Michal Hocko wrote:
> - we have grown a new get_user_pages_longterm. It is an ugly API and
>   I think we really need to have a decent page pinning one with the
>   accounting and limiting.

I'm interested in this topic from NVDIMM/DAX POV as well as due to other
issues filesystems currently have with GUP (more on that in a topic
proposal I'll send in a moment).

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
