Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id E4EC06B026F
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:32:33 -0400 (EDT)
Received: by wgjx7 with SMTP id x7so11781733wgj.2
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:32:33 -0700 (PDT)
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id r3si2483006wjo.69.2015.07.14.08.32.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 08:32:32 -0700 (PDT)
Received: by wgmn9 with SMTP id n9so11848274wgm.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:32:31 -0700 (PDT)
Date: Tue, 14 Jul 2015 17:32:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 7/8] memcg: get rid of mm_struct::owner
Message-ID: <20150714153229.GH17660@dhcp22.suse.cz>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
 <1436358472-29137-8-git-send-email-mhocko@kernel.org>
 <20150708173251.GG2436@esperanza>
 <20150709140941.GG13872@dhcp22.suse.cz>
 <20150710075400.GN2436@esperanza>
 <20150710124520.GA29540@dhcp22.suse.cz>
 <20150711070905.GO2436@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150711070905.GO2436@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Sat 11-07-15 10:09:06, Vladimir Davydov wrote:
[...]
> Why can't we make root_mem_cgroup statically allocated? AFAICS it's a
> common practice - e.g. see blkcg_root, root_task_group.

It's not that easy. mem_cgroup doesn't have a fixed size. It depends
on the number of online nodes. I haven't looked closer to this yet but
cgroup has an early init code path maybe we can hook in there.

I would like to settle with the current issues described in other email
first, though. This is just a cosmetic issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
