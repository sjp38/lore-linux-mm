Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E252B6B0032
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 01:30:40 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id 13so155605lba.34
        for <linux-mm@kvack.org>; Mon, 19 Aug 2013 22:30:39 -0700 (PDT)
Date: Tue, 20 Aug 2013 09:30:36 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 0/3] mm: mempolicy: the failure processing about
 mpol_to_str()
Message-ID: <20130820053036.GB18673@moon>
References: <5212E8DF.5020209@asianux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5212E8DF.5020209@asianux.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, rientjes@google.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Aug 20, 2013 at 11:56:15AM +0800, Chen Gang wrote:
> For the implementation (patch 1/3), need fill buffer as full as
> possible when buffer space is not enough.
> 
> For the caller (patch 2/3, 3/3), need check the return value of
> mpol_to_str().
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>

Won't simple check for mpol_to_str() < 0 be enough? IOW fix all
callers to check that mpol_to_str exit without errors. As far
as I see here are only two users. Something like

show_numa_map
	ret = mpol_to_str();
	if (ret)
		return ret;

shmem_show_mpol
	ret = mpol_to_str();
	if (ret)
		return ret;

sure you'll have to change shmem_show_mpol statement to return int code.
Won't this be more short and convenient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
