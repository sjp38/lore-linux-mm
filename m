Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 62AEA6B008A
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 11:34:58 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id a108so4652207qge.22
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 08:34:58 -0700 (PDT)
Received: from mail-qg0-x22d.google.com (mail-qg0-x22d.google.com [2607:f8b0:400d:c04::22d])
        by mx.google.com with ESMTPS id v3si13750326qab.62.2014.06.06.08.34.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 08:34:57 -0700 (PDT)
Received: by mail-qg0-f45.google.com with SMTP id z60so4779515qgd.32
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 08:34:57 -0700 (PDT)
Date: Fri, 6 Jun 2014 11:34:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140606153454.GB14001@htj.dyndns.org>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
 <20140606152914.GA14001@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140606152914.GA14001@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

A bit of addition.

Let's *please* think through how memcg should be configured and
different knobs / limits interact with each other and come up with a
consistent scheme before adding more shits on top.  This "oh I know
this use case and maybe that behavior is necessary too, let's add N
different and incompatible ways to mix and match them" doesn't fly.
Aren't we suppposed to at least have learned that already?

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
