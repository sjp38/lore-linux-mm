Date: Thu, 20 Sep 2007 14:58:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 3/9] oom: change all_unreclaimable zone member to flags
In-Reply-To: <Pine.LNX.4.64.0709201454560.11226@schroedinger.engr.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709201457330.31824@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319300.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201319520.25753@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709201320521.25753@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0709201454560.11226@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Sep 2007, Christoph Lameter wrote:

> Additional work needed though: The setting of the reclaim flag can be 
> removed from outside of zone reclaim. A testset when zone reclaim starts 
> and a clear when it ends is enough.
> 

Ok, I'll queue this for after we get this patchset merged into -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
