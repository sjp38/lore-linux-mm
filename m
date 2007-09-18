Date: Tue, 18 Sep 2007 14:25:01 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 6/4] oom: pass null to kfree if zonelist is not cleared
In-Reply-To: <alpine.DEB.0.9999.0709181406490.31545@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709181423250.4494@schroedinger.engr.sgi.com>
References: <871b7a4fd566de081120.1187786931@v2.random>
 <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709180246580.21326@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181256260.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181306140.22984@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181314160.3953@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181340060.27785@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709181400440.4494@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709181406490.31545@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, David Rientjes wrote:

> If the kzalloc fails, we're in a system-wide OOM state that isn't 
> constrained by anything so we allow the OOM killer to be invoked just 
> like this patchset was never applied.  We make no inference that it has 
> already been invoked, there is nothing to suggest that it has.  All we 
> know is that none of the zones in the zonelist from __alloc_pages() are 
> currently in the OOM killer.

kzalloc can be restricted by the cpuset / mempolicy context and the 
GFP_THISNODE flags. It may fail for other reasons. Maybe passing some 
flags like (PF_MEMALLOC) to kzalloc will make it ignore those limits?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
