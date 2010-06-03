Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A90EA6B01AD
	for <linux-mm@kvack.org>; Thu,  3 Jun 2010 16:11:34 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id o53KBTMT002422
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:11:30 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by hpaq11.eem.corp.google.com with ESMTP id o53KBQRd024597
	for <linux-mm@kvack.org>; Thu, 3 Jun 2010 13:11:28 -0700
Received: by pwi9 with SMTP id 9so292009pwi.16
        for <linux-mm@kvack.org>; Thu, 03 Jun 2010 13:11:26 -0700 (PDT)
Date: Thu, 3 Jun 2010 13:11:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/5] oom: select_bad_process: check PF_KTHREAD instead
 of !mm to skip kthreads
In-Reply-To: <20100603142717.GC3548@redhat.com>
Message-ID: <alpine.DEB.2.00.1006031308430.10856@chino.kir.corp.google.com>
References: <20100601212023.GA24917@redhat.com> <alpine.DEB.2.00.1006011424200.16725@chino.kir.corp.google.com> <20100602223612.F52D.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006021405280.32666@chino.kir.corp.google.com> <20100602213331.GA31949@redhat.com>
 <alpine.DEB.2.00.1006021437010.4765@chino.kir.corp.google.com> <20100603142717.GC3548@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Jun 2010, Oleg Nesterov wrote:

> David, I don't understand why do you refuse to re-diff your changes
> on top of Kosaki's work. If nothing else, this will help to review
> your changes.
> 

I simply don't have enough time in a day to rebase my rewrite patches on 
top of what Andrew may or may not merge into -mm.  When he merges 
something, that would be different.

I don't think we need to push anything to -mm right now that isn't rc 
material since the rewrite should make it in before the merge window.  If 
there are outstanding fixes that should go into rc (and probably stable 
material as well), those need to be pushed to Andrew immediately.  I 
disagree that I've seen any to date that are immediate fixes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
