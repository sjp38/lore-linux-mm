Date: Tue, 4 Apr 2006 08:06:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 5/6] Swapless V1: Rip out swap migration code
In-Reply-To: <20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604040804560.26787@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
 <20060404065805.24532.65008.sendpatchset@schroedinger.engr.sgi.com>
 <20060404193714.2dfafa79.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lee.schermerhorn@hp.com, lhms-devel@lists.sourceforge.net, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Tue, 4 Apr 2006, KAMEZAWA Hiroyuki wrote:

> On Mon, 3 Apr 2006 23:58:05 -0700 (PDT)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Rip the page migration logic out
> > 
> 
> Thank you. I like this removal, especially removing remove_from_swap() :)

Have a look at remove_migration_ptes(). Like remove_from_swap() it has the 
requirement that the mmap_sem is held since that is the only secure way to 
make sure that the anon_vma is not vanishing from under us. That may be a 
problem if you are not coming from a process context. Any ideas on how to 
fix that?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
