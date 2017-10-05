Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 066086B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 05:13:49 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id u138so12726168wmu.2
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 02:13:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5si11948718wma.142.2017.10.05.02.13.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Oct 2017 02:13:47 -0700 (PDT)
Date: Thu, 5 Oct 2017 09:57:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
Message-ID: <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org>
 <20171004185906.GB2136@cmpxchg.org>
 <20171004153245.2b08d831688bb8c66ef64708@linux-foundation.org>
 <20171004231821.GA3610@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171004231821.GA3610@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed 04-10-17 19:18:21, Johannes Weiner wrote:
> On Wed, Oct 04, 2017 at 03:32:45PM -0700, Andrew Morton wrote:
[...]
> > You don't think they should be backported into -stables?
> 
> Good point. For this one, it makes sense to CC stable, for 4.11 and
> up. The second patch is more of a fortification against potential
> future issues, and probably shouldn't go into stable.

I am not against. It is true that the memory reserves depletion fix was
theoretical because I haven't seen any real life bug. I would argue that
the more robust allocation failure behavior is a stable candidate as
well, though, because the allocation can fail regardless of the vmalloc
revert. It is less likely but still possible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
