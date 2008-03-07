Date: Fri, 7 Mar 2008 00:56:33 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot
 time
In-Reply-To: <6599ad830803070040i5e54f5f3u9b4c753ac5a87771@mail.gmail.com>
Message-ID: <alpine.DEB.1.00.0803070055020.3470@chino.kir.corp.google.com>
References: <20080306185952.23290.49571.sendpatchset@localhost.localdomain>  <alpine.DEB.1.00.0803061108370.13110@chino.kir.corp.google.com>  <47D0C76D.8050207@linux.vnet.ibm.com>  <alpine.DEB.1.00.0803062111560.26462@chino.kir.corp.google.com>
 <6599ad830803070040i5e54f5f3u9b4c753ac5a87771@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 7 Mar 2008, Paul Menage wrote:

> >  Since the command line is logically delimited by spaces, you can
> >  accidently disable a subsystem if its name appears in any of your kernel
> >  options following your cgroup_disable= option.
> 
> I think that you're confusing this with things like the very early
> memory init setup parameters, which do operate on the raw commandline.
> 
> By the time anything is passed to a __setup() function, it's already
> been split into separate strings at space boundaries.
> 

Ok, so the cgroup_disable= parameter should be a list of subsystem names 
delimited by anything other than a space that the user wants disabled.  
That makes more sense, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
