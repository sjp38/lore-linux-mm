Date: Thu, 20 Sep 2007 14:56:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/9] oom: change all_unreclaimable zone member to flags
In-Reply-To: <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709201454560.11226@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> All flag operators are of the atomic variety because there are currently
> readers that are implemented that do not take zone->lock.

Acked-by: Christoph Lameter <clameter@sgi.com>

Additional work needed though: The setting of the reclaim flag can be 
removed from outside of zone reclaim. A testset when zone reclaim starts 
and a clear when it ends is enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
