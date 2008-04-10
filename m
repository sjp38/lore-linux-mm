Date: Thu, 10 Apr 2008 13:33:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/18] SLUB: Slab defrag core
In-Reply-To: <20080410120042.dc66f4f7.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804101332210.13275@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230226.847485429@sgi.com>
 <20080407231129.3c044ba1.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com>
 <20080408141135.de5a6350.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com>
 <20080408142505.4bfc7a4d.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0804081441350.31620@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0804101126280.12367@schroedinger.engr.sgi.com>
 <20080410120042.dc66f4f7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, mel@skynet.ie, andi@firstfloor.org, npiggin@suse.de, riel@redhat.com, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008, Andrew Morton wrote:

> > +		static unsigned long global_objects_freed = 0;
> 
> Wanna buy a patch-checking script?  It's real cheap!

Its a strange variable definition that people should pay 
attention to. = 0 would at least make me notice instead of just assuming
its just another of those local variables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
