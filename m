Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F3F226B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:01:36 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp04.au.ibm.com (8.14.3/8.13.1) with ESMTP id o13Gw0vU022107
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 03:58:00 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o13H1WZF1769506
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 04:01:32 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o13H1VL7006577
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 04:01:32 +1100
Date: Wed, 3 Feb 2010 22:31:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Improving OOM killer
Message-ID: <20100203170127.GH19641@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <201002012302.37380.l.lunak@suse.cz>
 <4B698CEE.5020806@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4B698CEE.5020806@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

* Rik van Riel <riel@redhat.com> [2010-02-03 09:49:18]:

> On 02/01/2010 05:02 PM, Lubos Lunak wrote:
> 
> >  In other words, use VmRSS for measuring memory usage instead of VmSize, and
> >remove child accumulating.
> 
> I agree with removing the child accumulating code.  That code can
> do a lot of harm with databases like postgresql, or cause the
> system's main service (eg. httpd) to be killed when a broken cgi
> script used up too much memory.
>
> IIRC the child accumulating code was introduced to deal with
> malicious code (fork bombs), but it makes things worse for the
> (much more common) situation of a system without malicious
> code simply running out of memory due to being very busy.
>

For fork bombs, we could do a number of children number test and have
a threshold before we consider a process and its children for
badness().

> I have no strong opinion on using RSS vs VmSize.
> 

David commented and feels strongly about RSS and prefers VmSize.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
