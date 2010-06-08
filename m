Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3CB6B01C8
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 19:28:15 -0400 (EDT)
Date: Tue, 8 Jun 2010 16:28:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 03/18] oom: select task from tasklist for mempolicy
 ooms
Message-Id: <20100608162807.d73d02ef.akpm@linux-foundation.org>
In-Reply-To: <20100607085714.8750.A69D9226@jp.fujitsu.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006010013360.29202@chino.kir.corp.google.com>
	<20100607085714.8750.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  8 Jun 2010 20:41:52 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > -			panic("out of memory. panic_on_oom is selected\n");
> > +			panic("Out of memory: panic_on_oom is enabled\n");
> 
> you shouldn't immix undocumented and unnecessary change.

Well...  strictly true.  But there's not a lot of benefit in being all
dogmatic about these things.  If the change is simple and is of some
benefit and deosn't muck up the patch too much, I just let it go, shrug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
