Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 61CBB6B0044
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 08:57:12 -0400 (EDT)
Date: Fri, 12 Oct 2012 14:57:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] add some drop_caches documentation and info messsge
Message-ID: <20121012125708.GJ10110@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi,
I would like to resurrect the following Dave's patch. The last time it
has been posted was here https://lkml.org/lkml/2010/9/16/250 and there
didn't seem to be any strong opposition. 
Kosaki was worried about possible excessive logging when somebody drops
caches too often (but then he claimed he didn't have a strong opinion
on that) but I would say opposite. If somebody does that then I would
really like to know that from the log when supporting a system because
it almost for sure means that there is something fishy going on. It is
also worth mentioning that only root can write drop caches so this is
not an flooding attack vector.
I am bringing that up again because this can be really helpful when
chasing strange performance issues which (surprise surprise) turn out to
be related to artificially dropped caches done because the admin thinks
this would help...

I have just refreshed the original patch on top of the current mm tree
but I could live with KERN_INFO as well if people think that KERN_NOTICE
is too hysterical.
---
