Date: Fri, 28 Apr 2006 17:36:50 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/7] page migration: Reorder functions in migrate.c
Message-Id: <20060428173650.146a6605.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0604281712210.4170@schroedinger.engr.sgi.com>
References: <20060428060302.30257.76871.sendpatchset@schroedinger.engr.sgi.com>
	<20060428150806.057b0bac.akpm@osdl.org>
	<Pine.LNX.4.64.0604281556220.3412@schroedinger.engr.sgi.com>
	<20060428161830.7af8c3f0.akpm@osdl.org>
	<Pine.LNX.4.64.0604281712210.4170@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, lee.schermerhorn@hp.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

hm.  migrate_pages() locks two pages at the same time.  We've avoided doing
that.

a) what prevents ab/ba deadlocks in the migration code?

b) if some other part of the kernel later decides to lock two pages at
   the same time, what protocol should that code follow to avoid ab/ba
   deadlocks?   lowest-pfn-first might be one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
