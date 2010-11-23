Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 269E86B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 17:53:15 -0500 (EST)
Date: Tue, 23 Nov 2010 23:52:44 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [BUG] memcg: fix false positive VM_BUG on non-SMP
Message-ID: <20101123225244.GB22484@cmpxchg.org>
References: <1290520130-9990-1-git-send-email-kirill@shutemov.name>
 <20101123121606.c07197e5.akpm@linux-foundation.org>
 <20101123210255.GA22484@cmpxchg.org>
 <20101123142247.e8566e3e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101123142247.e8566e3e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutsemov" <kirill@shutemov.name>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 02:22:47PM -0800, Andrew Morton wrote:
> On Tue, 23 Nov 2010 22:02:55 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Tue, Nov 23, 2010 at 12:16:06PM -0800, Andrew Morton wrote:
> > > On Tue, 23 Nov 2010 15:48:50 +0200
> > > "Kirill A. Shutsemov" <kirill@shutemov.name> wrote:
> > > 
> > > > ------------[ cut here ]------------
> > > > kernel BUG at mm/memcontrol.c:2155!
> > > 
> > > This bug has been there for a year, from which I conclude people don't
> > > run memcg on uniprocessor machines a lot.
> > > 
> > > Which is a bit sad, really.  Small machines need resource control too,
> > > perhaps more than large ones..
> > 
> > Admittedly, this patch is compile-tested on UP only, but it should be
> > obvious enough.
> > 
> > ---
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > Subject: [patch] memcg: fix page cgroup lock assert on UP
> > 
> > Page cgroup locking primitives use the bit spinlock API functions,
> > which do nothing on UP.
> > 
> > Thus, checking the lock state can not be done by looking at the bit
> > directly, but one has to go through the bit spinlock API as well.
> > 
> > This fixes a guaranteed UP bug, where asserting the page cgroup lock
> > bit as a sanity check crashes the kernel.
> > 
> 
> hm, your patch is the same as Kirill's, except you named it
> page_is_cgroup_locked() rather than is_page_cgroup_locked().  I guess
> page_is_cgroup_locked() is a bit better.

I had not sorted by threads and somehow assumed this was another
forward from you of a bugzilla report or something.  I didn't see
Kirill's patch until now.  Sorry!

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
