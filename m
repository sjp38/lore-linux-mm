From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][-mm] Add an owner to the mm_struct (v4)
Date: Wed, 2 Apr 2008 13:53:57 +0900
Message-ID: <20080402135357.04c3e79f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080401124312.23664.64616.sendpatchset@localhost.localdomain>
	<20080402093157.e445acfb.kamezawa.hiroyu@jp.fujitsu.com>
	<47F2FCAE.7070401@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756756AbYDBEtu@vger.kernel.org>
In-Reply-To: <47F2FCAE.7070401@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: linux-mm.kvack.org

On Wed, 02 Apr 2008 08:55:34 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > 
> >> +	/*
> >> +	 * Search through everything else. We should not get
> >> +	 * here often
> >> +	 */
> >> +	do_each_thread(g, c) {
> >> +		if (c->mm == mm)
> >> +			goto assign_new_owner;
> >> +	} while_each_thread(g, c);
> > 
> > Doing above in synchronized manner seems too heavy.
> > When this happen ? or Can this be done in lazy "on-demand" manner ?
> > 
> 
> Do you mean under task_lock()?
> 
No, scanning itself. 
How rarely this scan happens under a server which has 10000- threads ?

Thanks,
-Kame
