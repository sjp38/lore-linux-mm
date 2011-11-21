Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 29E486B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 03:05:59 -0500 (EST)
Date: Mon, 21 Nov 2011 09:05:54 +0100
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
Message-ID: <20111121080554.GB1625@x4.trippels.de>
References: <20111118072519.GA1615@x4.trippels.de>
 <20111118075521.GB1615@x4.trippels.de>
 <1321605837.30341.551.camel@debian>
 <20111118085436.GC1615@x4.trippels.de>
 <20111118120201.GA1642@x4.trippels.de>
 <1321836285.30341.554.camel@debian>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321836285.30341.554.camel@debian>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

On 2011.11.21 at 08:44 +0800, Alex,Shi wrote:
> On Fri, 2011-11-18 at 20:02 +0800, Markus Trippelsdorf wrote:
> > On 2011.11.18 at 09:54 +0100, Markus Trippelsdorf wrote:
> > > On 2011.11.18 at 16:43 +0800, Alex,Shi wrote:
> > > > > > 
> > > > > > The dirty flag comes from a bunch of unrelated xfs patches from Christoph, that
> > > > > > I'm testing right now.
> > > > 
> > > > Where is the xfs patchset? I am wondering if it is due to slub code. 
> > 
> > I begin to wonder if this might be the result of a compiler bug. 
> > The kernel in question was compiled with gcc version 4.7.0 20111117. And
> > there was commit to the gcc repository today that looks suspicious:
> > http://gcc.gnu.org/viewcvs?view=revision&revision=181466
> > 
> 
> Tell us if it is still there and you can reproduce it.

Hm, just noticed the "3.2.0-rc1 panic on PowerPC" thread:
http://thread.gmane.org/gmane.linux.kernel/1215584

The backtraces look suspiciously similar to mine.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
