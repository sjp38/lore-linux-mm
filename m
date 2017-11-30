Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB1566B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 04:53:27 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d4so2574909plr.8
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 01:53:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si2903621pla.69.2017.11.30.01.53.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 30 Nov 2017 01:53:26 -0800 (PST)
Date: Thu, 30 Nov 2017 10:53:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 1/4] mm: introduce get_user_pages_longterm
Message-ID: <20171130095323.ovrq2nenb6ztiapy@dhcp22.suse.cz>
References: <151197872943.26211.6551382719053304996.stgit@dwillia2-desk3.amr.corp.intel.com>
 <151197873499.26211.11687422577653326365.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151197873499.26211.11687422577653326365.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hch@lst.de, stable@vger.kernel.org, linux-nvdimm@lists.01.org

On Wed 29-11-17 10:05:35, Dan Williams wrote:
> Until there is a solution to the dma-to-dax vs truncate problem it is
> not safe to allow long standing memory registrations against
> filesytem-dax vmas. Device-dax vmas do not have this problem and are
> explicitly allowed.
> 
> This is temporary until a "memory registration with layout-lease"
> mechanism can be implemented for the affected sub-systems (RDMA and
> V4L2).

One thing is not clear to me. Who is allowed to pin pages for ever?
Is it possible to pin LRU pages that way as well? If yes then there
absolutely has to be a limit for that. Sorry I could have studied the
code much more but from a quick glance it seems to me that this is not
limited to dax (or non-LRU in general) pages.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
