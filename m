Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f41.google.com (mail-qe0-f41.google.com [209.85.128.41])
	by kanga.kvack.org (Postfix) with ESMTP id EEF276B0031
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:21:55 -0500 (EST)
Received: by mail-qe0-f41.google.com with SMTP id gh4so4139056qeb.14
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:21:55 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id k6si12056352qej.128.2013.12.16.09.21.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 09:21:55 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id w5so1748422qac.0
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:21:54 -0800 (PST)
Date: Mon, 16 Dec 2013 12:21:43 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: 3.13-rc breaks MEMCG_SWAP
Message-ID: <20131216172143.GJ32509@htj.dyndns.org>
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
 <52AEC989.4080509@huawei.com>
 <20131216095345.GB23582@dhcp22.suse.cz>
 <20131216104042.GC23582@dhcp22.suse.cz>
 <20131216163530.GH32509@htj.dyndns.org>
 <20131216171937.GG26797@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131216171937.GG26797@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Li Zefan <lizefan@huawei.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Hey,

On Mon, Dec 16, 2013 at 06:19:37PM +0100, Michal Hocko wrote:
> I have to think about it some more (the brain is not working anymore
> today). But what we really need is that nobody gets the same id while
> the css is alive. So css_from_id returning NULL doesn't seem to be
> enough.

Oh, I meant whether it's necessary to keep css_from_id() working
(ie. doing successful lookups) between offline and release, because
that's where lifetimes are coupled.  IOW, if it's enough for cgroup to
not recycle the ID until all css's are released && fail css_from_id()
lookup after the css is offlined, I can make a five liner quick fix.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
