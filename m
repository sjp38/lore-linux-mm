Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id EF86B6B00F0
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 10:37:32 -0400 (EDT)
Date: Wed, 7 Aug 2013 16:37:27 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/3] memcg: limit the number of thresholds per-memcg
Message-ID: <20130807143727.GA13279@dhcp22.suse.cz>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <20130807132210.GD27006@htj.dyndns.org>
 <20130807134654.GJ8184@dhcp22.suse.cz>
 <20130807135818.GG27006@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807135818.GG27006@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Wed 07-08-13 09:58:18, Tejun Heo wrote:
> Hello,
> 
> On Wed, Aug 07, 2013 at 03:46:54PM +0200, Michal Hocko wrote:
> > OK, I have obviously misunderstood your concern mentioned in the other
> > email. Could you be more specific what is the DoS scenario which was
> > your concern, then?
> 
> So, let's say the file is write-accessible to !priv user which is
> under reasonable resource limits.  Normally this shouldn't affect priv
> system tools which are monitoring the same event as it shouldn't be
> able to deplete resources as long as the resource control mechanisms
> are configured and functioning properly; however, the memory usage
> event puts all event listeners into a single contiguous table which a
> !priv user can easily expand to a size where the table can no longer
> be enlarged and if a priv system tool or another user tries to
> register event afterwards, it'll fail.  IOW, it creates a shared
> resource which isn't properly provisioned and can be trivially filled
> up making it an easy DoS target.

OK, got your point. You are right and I haven't considered the size of
the table and the size restrictions of kmalloc. Thanks for pointing this
out!
---
