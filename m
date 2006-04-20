Date: Thu, 20 Apr 2006 13:17:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Read/Write migration entries: Implement correct behavior in
 copy_one_pte
In-Reply-To: <20060419123911.3bd22ab3.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604201307200.19049@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0604181119480.7814@schroedinger.engr.sgi.com>
 <20060419095044.d7333b21.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604181823590.9747@schroedinger.engr.sgi.com>
 <20060419123911.3bd22ab3.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: hugh@veritas.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Apr 2006, KAMEZAWA Hiroyuki wrote:

> BTW, do we manage page table under move_vma() in right way ?

I had a look at it and it seems to be done the right way. The ptl locks
are taken and the vma information is setup before the move. 
remove_migration_ptes() will find the page both in the old and the new 
vma.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
