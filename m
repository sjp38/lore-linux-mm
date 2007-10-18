Date: Thu, 18 Oct 2007 17:33:31 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [Patch](memory hotplug) Make kmem_cache_node for SLUB on memory online to avoid panic(take 3)
In-Reply-To: <20071018000004.cf4727e7.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0710172321550.11401@schroedinger.engr.sgi.com> <20071018000004.cf4727e7.akpm@linux-foundation.org>
Message-Id: <20071018171917.5159.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 17 Oct 2007 23:25:58 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> 
> > > So that's slub.  Does slab already have this functionality or are you
> > > not bothering to maintain slab in this area?
> > 
> > Slab brings up a per node structure when the corresponding cpu is brought 
> > up. That was sufficient as long as we did not have any memoryless nodes. 

Right. At least, I don't have any experience of panic with SLAB so far.
(If panic occurred, I already made a patch.).

> > Now we may have to fix some things over there as well.

Though the fix may be better for it, my priority is very low for it
now.



-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
