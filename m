Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 096FD6B004D
	for <linux-mm@kvack.org>; Tue, 18 Aug 2009 08:43:15 -0400 (EDT)
Date: Tue, 18 Aug 2009 20:00:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and
	'slabinfo'
Message-ID: <20090818120032.GA22152@localhost>
References: <20090817094525.6355.88682.sendpatchset@localhost.localdomain> <20090817094822.GA17838@elte.hu> <1250502847.5038.16.camel@penberg-laptop> <alpine.DEB.1.10.0908171228300.16267@gentwo.org> <4A8986BB.80409@cs.helsinki.fi> <alpine.DEB.1.10.0908171240370.16267@gentwo.org> <4A8A0B0D.6080400@redhat.com> <4A8A0B14.8040700@cn.fujitsu.com> <4A8A1B2E.20505@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A8A1B2E.20505@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Amerigo Wang <amwang@redhat.com>
Cc: Li Zefan <lizf@cn.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 11:08:30AM +0800, Amerigo Wang wrote:

> -	proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> +	proc_create("slabinfo",S_IRUGO,NULL,&proc_slabinfo_operations);

Style nitpick. The spaces were packed to fit into 80-col I guess.


ERROR: space required after that ',' (ctx:VxV)
#10: FILE: mm/slub.c:4729:
+       proc_create("slabinfo",S_IRUGO,NULL,&proc_slabinfo_operations);
                              ^

ERROR: space required after that ',' (ctx:VxV)
#10: FILE: mm/slub.c:4729:
+       proc_create("slabinfo",S_IRUGO,NULL,&proc_slabinfo_operations);
                                      ^

ERROR: space required after that ',' (ctx:VxO)
#10: FILE: mm/slub.c:4729:
+       proc_create("slabinfo",S_IRUGO,NULL,&proc_slabinfo_operations);
                                           ^

ERROR: space required before that '&' (ctx:OxV)
#10: FILE: mm/slub.c:4729:
+       proc_create("slabinfo",S_IRUGO,NULL,&proc_slabinfo_operations);
                                            ^

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
