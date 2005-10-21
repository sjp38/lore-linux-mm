Date: Fri, 21 Oct 2005 11:26:13 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
In-Reply-To: <20051021111004.757a1c77.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0510211125080.23833@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
 <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
 <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
 <435896CA.1000101@jp.fujitsu.com> <20051021081553.50716b97.pj@sgi.com>
 <43590789.1070309@jp.fujitsu.com> <20051021111004.757a1c77.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Simon.Derr@bull.net, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, Paul Jackson wrote:

> Kame wroteL
> > I'm just afraid of swapped-out pages will goes back to original nodes
> 
> The pages could end up there, yes, if that's where they are faulted
> back into.

Right. But the cpuset code will change the mems_allowed. The pages will 
then be allocated in that context.

> In general, the swap-based migration method does not guarantee
> where the pages will end up.  The more difficult direct node-to-node
> migration method will be needed to guarantee that.

Correct, tt does not guarantee that without cpuset assistance. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
