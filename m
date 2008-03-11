Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m2BFuABI010160
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 15:56:10 GMT
Received: from wx-out-0506.google.com (wxcs14.prod.google.com [10.70.120.14])
	by zps36.corp.google.com with ESMTP id m2BFtS8Z019543
	for <linux-mm@kvack.org>; Tue, 11 Mar 2008 08:56:09 -0700
Received: by wx-out-0506.google.com with SMTP id s14so2810833wxc.26
        for <linux-mm@kvack.org>; Tue, 11 Mar 2008 08:56:08 -0700 (PDT)
Message-ID: <6599ad830803110856j5333f032n2e26fb51111a839c@mail.gmail.com>
Date: Tue, 11 Mar 2008 08:56:08 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 2/2] Make res_counter hierarchical
In-Reply-To: <47D64E0A.3090907@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <47D16004.7050204@openvz.org>
	 <20080308134514.434f38f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <47D63FBC.1010805@openvz.org>
	 <6599ad830803110157u71fe6c3cse125d0202610413b@mail.gmail.com>
	 <20080311181325.c0bf6b90.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830803110211u1cb48874l30aa75d21dc2b23@mail.gmail.com>
	 <47D64E0A.3090907@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Linux Containers <containers@lists.osdl.org>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 11, 2008 at 2:16 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> Paul Menage wrote:
>  > On Tue, Mar 11, 2008 at 2:13 AM, KAMEZAWA Hiroyuki
>  > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  >>  or remove all relationship among counters of *different* type of resources.
>  >>  user-land-daemon will do enough jobs.
>  >>
>  >
>  > Yes, that would be my preferred choice, if people agree that
>  > hierarchically limiting overall virtual memory isn't useful. (I don't
>  > think I have a use for it myself).
>  >
>
>  Virtual limits are very useful. I have a patch ready to send out.
>  They limit the amount of paging a cgroup can do (virtual limit - RSS limit).

Ah, from this should I assume that you're talking about virtual
address space limits, not virtual memory limits?

My comment above was referring to Pavel's proposal to limit total
virtual memory (RAM + swap) for a cgroup, and then limit swap as a
subset of that, which basically makes it impossible to limit the RAM
usage of cgroups properly if you also want to allow swap usage.

Virtual address space limits are somewhat orthogonal to that.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
