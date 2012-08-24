Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 7032F6B005D
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 15:54:49 -0400 (EDT)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 24 Aug 2012 15:54:44 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id D982438C8041
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 15:54:10 -0400 (EDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OJs9DE184680
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 15:54:10 -0400
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OJrxPY002353
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 13:54:00 -0600
Date: Fri, 24 Aug 2012 12:53:57 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] kmemleak: replace list_for_each_continue_rcu with
 new interface
Message-ID: <20120824195357.GR2472@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <502CB92F.2010700@linux.vnet.ibm.com>
 <502DC99E.4060408@linux.vnet.ibm.com>
 <5036D062.7070003@linux.vnet.ibm.com>
 <20120824100505.GG7585@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120824100505.GG7585@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Michael Wang <wangyun@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Aug 24, 2012 at 11:05:05AM +0100, Catalin Marinas wrote:
> On Fri, Aug 24, 2012 at 01:52:50AM +0100, Michael Wang wrote:
> > On 08/17/2012 12:33 PM, Michael Wang wrote:
> > > From: Michael Wang <wangyun@linux.vnet.ibm.com>
> > > 
> > > This patch replaces list_for_each_continue_rcu() with
> > > list_for_each_entry_continue_rcu() to save a few lines
> > > of code and allow removing list_for_each_continue_rcu().
> > 
> > Could I get some comments on this patch?
> 
> Sorry, busy with other things and forgot about this.
> 
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>

Queued, thank you both!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
