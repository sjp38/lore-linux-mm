Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED8C6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 10:40:24 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id w8so7359838qac.8
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:40:24 -0700 (PDT)
Received: from mail-qa0-x235.google.com (mail-qa0-x235.google.com [2607:f8b0:400d:c00::235])
        by mx.google.com with ESMTPS id r2si13464856qat.30.2014.06.16.07.40.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 07:40:24 -0700 (PDT)
Received: by mail-qa0-f53.google.com with SMTP id j15so7394361qaq.26
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 07:40:24 -0700 (PDT)
Date: Mon, 16 Jun 2014 10:40:21 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140616144021.GC11542@htj.dyndns.org>
References: <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
 <20140612142237.GB32720@dhcp22.suse.cz>
 <20140612161733.GC23606@htj.dyndns.org>
 <20140616125915.GB16915@dhcp22.suse.cz>
 <20140616135741.GA11542@htj.dyndns.org>
 <20140616140448.GE16915@dhcp22.suse.cz>
 <20140616141233.GB11542@htj.dyndns.org>
 <20140616142915.GF16915@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140616142915.GF16915@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Mon, Jun 16, 2014 at 04:29:15PM +0200, Michal Hocko wrote:
> > They're all in the mainline now.
> 
> git grep CFTYPE_ON_ON_DFL origin/master didn't show me anything.

lol, it should have been CFTYPE_ONLY_ON_DFL.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
