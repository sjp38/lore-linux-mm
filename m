Date: Tue, 11 Mar 2008 18:13:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
Message-Id: <20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
References: <47D16004.7050204@openvz.org>
	<20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	<47D63FBC.1010805@openvz.org>
	<6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelyanov <xemul@openvz.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Mar 2008 01:57:43 -0700
"Paul Menage" <menage@google.com> wrote:

> Alternatively, you could make it possible for a res_counter to have
> multiple parents (each of which constrains the overall usage of it and
> its siblings), and have three counters for each cgroup:
> 
> - vm_counter: overall virtual memory limit for group, parent =
> parent_mem_cgroup->vm_counter
> 
> - mem_counter: main memory limit for group, parents = vm_counter,
> parent_mem_cgroup->mem_counter
> 
> - swap_counter: swap limit for group, parents = vm_counter,
> parent_mem_cgroup->swap_counter
> 
or remove all relationship among counters of *different* type of resources.
user-land-daemon will do enough jobs.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
