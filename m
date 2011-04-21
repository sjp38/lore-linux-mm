Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 23D788D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:37:31 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110421221712.9184.A69D9226@jp.fujitsu.com>
References: <1303337718.2587.51.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com>
	 <20110421221712.9184.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 11:37:27 -0500
Message-ID: <1303403847.4025.11.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Thu, 2011-04-21 at 22:16 +0900, KOSAKI Motohiro wrote:
> > This should fix the remaining architectures so they can use CONFIG_SLUB, 
> > but I hope it can be tested by the individual arch maintainers like you 
> > did for parisc.
> 
> ia64 and mips have CONFIG_ARCH_POPULATES_NODE_MAP and it initialize
> N_NORMAL_MEMORY automatically if my understand is correct.
> (plz see free_area_init_nodes)
> 
> I guess alpha and m32r have no active developrs. only m68k seems to be need
> fix and we have a chance to get a review... 

Actually, it's not quite a fix yet, I'm afraid.  I've just been
investigating why my main 4 way box got slower with kernel builds:
Apparently userspace processes are now all stuck on CPU0, so we're
obviously tripping over some NUMA scheduling stuff that's missing.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
