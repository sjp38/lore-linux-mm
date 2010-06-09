Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1DC8F6B01D9
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 20:06:40 -0400 (EDT)
Date: Tue, 8 Jun 2010 17:06:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch -mm 01/18] oom: filter tasks not sharing the same cpuset
Message-Id: <20100608170630.80753ed1.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006081654020.19582@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006010008410.29202@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006010013080.29202@chino.kir.corp.google.com>
	<20100607084024.873B.A69D9226@jp.fujitsu.com>
	<alpine.DEB.2.00.1006081141330.18848@chino.kir.corp.google.com>
	<20100608162513.c633439e.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1006081654020.19582@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jun 2010 16:54:31 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 8 Jun 2010, Andrew Morton wrote:
> 
> > And I wonder if David has observed some problem which the 2010 change
> > fixes!
> > 
> 
> Yes, as explained in my changelog.  I'll paste it:
> 
> Tasks that do not share the same set of allowed nodes with the task that
> triggered the oom should not be considered as candidates for oom kill.
> 
> Tasks in other cpusets with a disjoint set of mems would be unfairly
> penalized otherwise because of oom conditions elsewhere; an extreme
> example could unfairly kill all other applications on the system if a
> single task in a user's cpuset sets itself to OOM_DISABLE and then uses
> more memory than allowed.

OK, so Nick's change didn't anticipate things being set to OOM_DISABLE?

OOM_DISABLE seems pretty dangerous really - allows malicious
unprivileged users to go homicidal?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
