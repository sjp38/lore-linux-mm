From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17240.54704.515573.252722@gargle.gargle.HOWL>
Date: Fri, 21 Oct 2005 15:49:04 +0400
Subject: Re: [PATCH 1/4] Swap migration V3: LRU operations
In-Reply-To: <1129874762.26533.5.camel@localhost>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	<20051020225940.19761.93396.sendpatchset@schroedinger.engr.sgi.com>
	<1129874762.26533.5.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Mike Kravetz <kravetz@us.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Magnus Damm <magnus.damm@gmail.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen writes:

[...]

 > 
 > It makes much more sense to have something like:
 > 
 >         if (ret == ISOLATION_IMPOSSIBLE) {
 >         	 list_del(&page->lru);
 >          	 list_add(&page->lru, src);
 >         }
 > 
 > than
 > 
 > +               if (rc == -1) {  /* Not possible to isolate */
 > +                       list_del(&page->lru);
 > +                       list_add(&page->lru, src);
 > +                } if 

And
         if (ret == ISOLATION_IMPOSSIBLE)
          	 list_move(&page->lru, src);

is even better.

Nikita.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
