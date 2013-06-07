Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id B7CF46B0032
	for <linux-mm@kvack.org>; Fri,  7 Jun 2013 09:12:00 -0400 (EDT)
Date: Fri, 7 Jun 2013 15:11:57 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH for 3.2] memcg: do not trap chargers with full callstack on
 OOM
Message-ID: <20130607131157.GF8117@dhcp22.suse.cz>
References: <20130208152402.GD7557@dhcp22.suse.cz>
 <20130208165805.8908B143@pobox.sk>
 <20130208171012.GH7557@dhcp22.suse.cz>
 <20130208220243.EDEE0825@pobox.sk>
 <20130210150310.GA9504@dhcp22.suse.cz>
 <20130210174619.24F20488@pobox.sk>
 <20130211112240.GC19922@dhcp22.suse.cz>
 <20130222092332.4001E4B6@pobox.sk>
 <20130606160446.GE24115@dhcp22.suse.cz>
 <20130606181633.BCC3E02E@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130606181633.BCC3E02E@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu 06-06-13 18:16:33, azurIt wrote:
> Hello Michal,
> 
> nice to read you! :) Yes, i'm still on 3.2. Could you be so kind and
> try to backport it? Thank you very much!

Here we go. I hope I didn't screw anything (Johannes might double check)
because there were quite some changes in the area since 3.2. Nothing
earth shattering though. Please note that I have only compile tested
this. Also make sure you remove the previous patches you have from me.
---
