Received: by zproxy.gmail.com with SMTP id z3so620881nzf
        for <linux-mm@kvack.org>; Thu, 09 Mar 2006 22:05:45 -0800 (PST)
Message-ID: <aec7e5c30603092204h21fa7639wf90e6d4e2fdee128@mail.gmail.com>
Date: Fri, 10 Mar 2006 15:04:15 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 03/03] Unmapped: Add guarantee code
In-Reply-To: <44110727.802@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20060310034412.8340.90939.sendpatchset@cherry.local>
	 <20060310034429.8340.61997.sendpatchset@cherry.local>
	 <44110727.802@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Magnus Damm <magnus@valinux.co.jp>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/10/06, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Magnus Damm wrote:
> > Implement per-LRU guarantee through sysctl.
> >
> > This patch introduces the two new sysctl files "node_mapped_guar" and
> > "node_unmapped_guar". Each file contains one percentage per node and tells
> > the system how many percentage of all pages that should be kept in RAM as
> > unmapped or mapped pages.
> >
>
> The whole Linux VM philosophy until now has been to get away from stuff
> like this.

Yeah, and Linux has never supported memory resource control either, right?

> If your app is really that specialised then maybe it can use mlock. If
> not, maybe the VM is currently broken.
>
> You do have a real-world workload that is significantly improved by this,
> right?

Not really, but I think there is a demand for memory resource control today.

The memory controller in ckrm also breaks out the LRU, but puts one
LRU instance in each class. My code does not depend on ckrm, but it
should be possible to have some kind of resource control with this
patch and cpusets. And yeah, add numa emulation if you are out of
nodes. =)

Thanks,

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
