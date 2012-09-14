Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id E2DCD6B01F6
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 05:56:56 -0400 (EDT)
Date: Fri, 14 Sep 2012 11:56:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/memcontrol.c: Remove duplicate inclusion of sock.h
 file
Message-ID: <20120914095653.GD28039@dhcp22.suse.cz>
References: <1347350934-17712-1-git-send-email-sachin.kamat@linaro.org>
 <20120911095200.GB8058@dhcp22.suse.cz>
 <20120912072520.GB17516@dhcp22.suse.cz>
 <50504CE1.8030509@parallels.com>
 <20120912125647.GH21579@dhcp22.suse.cz>
 <20120912130935.GJ21579@dhcp22.suse.cz>
 <CAK9yfHwMnC65BvY3RG7duf_Cmt5hf1VLV=vZRag4Mm6nHdQ-GA@mail.gmail.com>
 <20120914082741.GC28039@dhcp22.suse.cz>
 <5052EBAD.6060202@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5052EBAD.6060202@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Sachin Kamat <sachin.kamat@linaro.org>, cgroups@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri 14-09-12 12:32:45, Glauber Costa wrote:
> On 09/14/2012 12:27 PM, Michal Hocko wrote:
> > On Fri 14-09-12 13:28:07, Sachin Kamat wrote:
> >> Hi Michal,
> >>
> >> Has this patch been accepted?
> > 
> > Not yet. I am waiting for Glauber to ack it.
> > 
> 
> I am fine with the change, assuming you tested it, after you made the
> change I requested.

OK, I will repost the patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
