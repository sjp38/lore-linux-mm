Date: Wed, 20 Sep 2006 10:30:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch00/05]: Containers(V2)- Introduction
In-Reply-To: <45117830.3080909@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0609201024310.31178@schroedinger.engr.sgi.com>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
 <4510D3F4.1040009@yahoo.com.au> <Pine.LNX.4.64.0609200925280.30572@schroedinger.engr.sgi.com>
 <451172AB.2070103@yahoo.com.au> <Pine.LNX.4.64.0609201006420.30793@schroedinger.engr.sgi.com>
 <45117830.3080909@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohitseth@google.com, pj@sgi.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 21 Sep 2006, Nick Piggin wrote:

> Patch 2/5 in this series provides hooks, and they are pretty unintrusive.

Ok. We shadow existing vm counters add stuff to the adress_space 
structure. The task add / remove is duplicating what some of the cpuset 
hooks do. That clearly shows that we are just duplicating functionality.

The mapping things are new.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
