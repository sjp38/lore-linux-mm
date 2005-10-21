Date: Fri, 21 Oct 2005 10:06:34 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
In-Reply-To: <20051021100357.3397269e.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0510211005090.23359@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
 <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
 <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
 <435896CA.1000101@jp.fujitsu.com> <Pine.LNX.4.62.0510210926120.23328@schroedinger.engr.sgi.com>
 <20051021100357.3397269e.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: kamezawa.hiroyu@jp.fujitsu.com, Simon.Derr@bull.net, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, Paul Jackson wrote:

> know what you intend to update mems_allowed to.  Currently, a task
> mems_allowed is only updated in task context, from its cpusets
> mems_allowed. The task mems_allowed is updated automatically coming
> into the page allocation code, if the tasks mems_generation doesn't
> match its cpusets mems_generation.

Therefore if mems_allowed is accessed from outside of the 
task then it may not be up to date, right?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
