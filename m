Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 3349E6B0044
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 06:05:35 -0400 (EDT)
Date: Fri, 24 Aug 2012 11:05:05 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 2/3] kmemleak: replace list_for_each_continue_rcu with
 new interface
Message-ID: <20120824100505.GG7585@arm.com>
References: <502CB92F.2010700@linux.vnet.ibm.com>
 <502DC99E.4060408@linux.vnet.ibm.com>
 <5036D062.7070003@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5036D062.7070003@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On Fri, Aug 24, 2012 at 01:52:50AM +0100, Michael Wang wrote:
> On 08/17/2012 12:33 PM, Michael Wang wrote:
> > From: Michael Wang <wangyun@linux.vnet.ibm.com>
> > 
> > This patch replaces list_for_each_continue_rcu() with
> > list_for_each_entry_continue_rcu() to save a few lines
> > of code and allow removing list_for_each_continue_rcu().
> 
> Could I get some comments on this patch?

Sorry, busy with other things and forgot about this.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
