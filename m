Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id mA46bXjW027566
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:37:33 -0800
Received: from rv-out-0708.google.com (rvfc5.prod.google.com [10.140.180.5])
	by wpaz29.hot.corp.google.com with ESMTP id mA46bReF020318
	for <linux-mm@kvack.org>; Mon, 3 Nov 2008 22:37:32 -0800
Received: by rv-out-0708.google.com with SMTP id c5so2898786rvf.56
        for <linux-mm@kvack.org>; Mon, 03 Nov 2008 22:37:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <490DCCC9.5000508@linux.vnet.ibm.com>
References: <20081101184812.2575.68112.sendpatchset@balbir-laptop>
	 <20081101184902.2575.11443.sendpatchset@balbir-laptop>
	 <20081102143817.99edca6d.kamezawa.hiroyu@jp.fujitsu.com>
	 <490D42C7.4000301@linux.vnet.ibm.com>
	 <20081102152412.2af29a1b.kamezawa.hiroyu@jp.fujitsu.com>
	 <490DCCC9.5000508@linux.vnet.ibm.com>
Date: Mon, 3 Nov 2008 22:37:31 -0800
Message-ID: <6599ad830811032237q14c065efx4316fee8f8daa515@mail.gmail.com>
Subject: Re: [mm] [PATCH 4/4] Memory cgroup hierarchy feature selector
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 2, 2008 at 7:52 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
> That should not be hard, but having it per-subtree sounds a little complex in
> terms of exploiting from the end-user perspective and from symmetry perspective
> (the CPU cgroup controller provides hierarchy control for the full hierarchy).
>

The difference is that the CPU controller works in terms of shares,
whereas memory works in terms of absolute memory size. So it pretty
much has to limit the hierarchy to a single tree. Also, I didn't think
that you could modify the shares for the root cgroup - what would that
mean if so?

With this patch set as it is now, the root cgroup's lock becomes a
global memory allocation/deallocation lock, which seems a bit painful.
Having a bunch of top-level cgroups each with their own independent
memory limits, and allowing sub cgroups of them to be constrained by
the parent's memory limit, seems more useful than a single hierarchy
connected at the root.

In what realistic circumstances do you actually want to limit the root
cgroup's memory usage?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
