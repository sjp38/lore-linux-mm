Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E35FD6B0069
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 03:43:50 -0500 (EST)
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <20111118075521.GB1615@x4.trippels.de>
References: <20111118072519.GA1615@x4.trippels.de>
	 <20111118075521.GB1615@x4.trippels.de>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 18 Nov 2011 16:43:57 +0800
Message-ID: <1321605837.30341.551.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

> > 
> > The dirty flag comes from a bunch of unrelated xfs patches from Christoph, that
> > I'm testing right now.

Where is the xfs patchset? I am wondering if it is due to slub code. It
is also possible xfs set a incorrect page flags. 

> > 
> > Please also see my previous post: http://thread.gmane.org/gmane.linux.kernel/1215023
> > It looks like something is scribbling over memory.
> > 
> > This machine uses ECC, so bit-flips should be impossible.
> 
> CC'ing netdev@vger.kernel.org and Eric Dumazet.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
