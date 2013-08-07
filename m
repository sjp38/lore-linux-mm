Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 9BB566B00B5
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 13:30:57 -0400 (EDT)
Date: Wed, 7 Aug 2013 19:30:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] memcg: Limit the number of events registered on
 oom_control
Message-ID: <20130807173051.GD16343@dhcp22.suse.cz>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <1375874907-22013-2-git-send-email-mhocko@suse.cz>
 <20130807130836.GB27006@htj.dyndns.org>
 <20130807133746.GI8184@dhcp22.suse.cz>
 <20130807134741.GF27006@htj.dyndns.org>
 <20130807135734.GK8184@dhcp22.suse.cz>
 <20130807144730.GB13279@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807144730.GB13279@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Wed 07-08-13 16:47:30, Michal Hocko wrote:
> On Wed 07-08-13 15:57:34, Michal Hocko wrote:
> [...]
> > Hmm, OK so you think that the fd limit is sufficient already?
> 
> Hmm, that would need to touch the code as well (the register callback
> would need to make sure only one event is registered per cfile). But yes
> this way would be better. I will send a new patch once I have an idle
> moment.

What do you think about the following? I am not sure about EINVAL maybe
there is a better way to tell userspace it is doing something wrong. I
would appreciate any suggestions. If this looks good I will post a
similar patch for vmpressure.
---
