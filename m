Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id C5E986B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 07:48:09 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id h10so2845922eak.16
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 04:48:09 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t6si4964051eeh.234.2013.12.17.04.48.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 04:48:08 -0800 (PST)
Date: Tue, 17 Dec 2013 13:48:07 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131217124807.GB28991@dhcp22.suse.cz>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
 <20131216172143.GJ32509@htj.dyndns.org>
 <alpine.LNX.2.00.1312161718001.2037@eggly.anvils>
 <52AFC163.5010507@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52AFC163.5010507@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 17-12-13 11:13:39, Li Zefan wrote:
> On 2013/12/17 9:41, Hugh Dickins wrote:
> > On Mon, 16 Dec 2013, Tejun Heo wrote:
> >> On Mon, Dec 16, 2013 at 06:19:37PM +0100, Michal Hocko wrote:
> >>> I have to think about it some more (the brain is not working anymore
> >>> today). But what we really need is that nobody gets the same id while
> >>> the css is alive.
> 
> That's what I meant to do in my last reply.
> 
> But I'm confused by
> 
> "How would this work? .. the swap will be there
> after the last reference to css as well."

Sorry about the confusion. Johannes correctly pointed out that a css
reference is taken when we record memcg id and released after the record
is removed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
