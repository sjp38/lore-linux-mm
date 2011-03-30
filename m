Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 516E48D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 19:30:54 -0400 (EDT)
Date: Thu, 31 Mar 2011 01:30:50 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 8/8] Add VM counters for transparent hugepages
Message-ID: <20110330233050.GG21838@one.firstfloor.org>
References: <20110307172609.8A01.A69D9226@jp.fujitsu.com> <20110307163513.GC13384@alboin.amr.corp.intel.com> <20110308114159.7EAD.A69D9226@jp.fujitsu.com> <20110330144507.2c0ecf73.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110330144507.2c0ecf73.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <ak@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Do we still want it?  Are we sure we don't want the per-zone numbers?

At least I still want it and Dave Hansen did too.

I don't need per zone personally and I remember a strong request from 
anyone.  Or was there one?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
