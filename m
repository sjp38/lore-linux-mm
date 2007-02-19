Received: by nf-out-0910.google.com with SMTP id b2so2210532nfe
        for <linux-mm@kvack.org>; Mon, 19 Feb 2007 01:16:42 -0800 (PST)
Message-ID: <aec7e5c30702190116j26efcba3oe5223584f99ac25a@mail.gmail.com>
Date: Mon, 19 Feb 2007 18:16:42 +0900
From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [RFC][PATCH][0/4] Memory controller (RSS Control)
In-Reply-To: <20070219005441.7fa0eccc.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	 <20070219005441.7fa0eccc.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@in.ibm.com>, linux-kernel@vger.kernel.org, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-mm@kvack.org, menage@google.com, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On 2/19/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 19 Feb 2007 12:20:19 +0530 Balbir Singh <balbir@in.ibm.com> wrote:
>
> > This patch applies on top of Paul Menage's container patches (V7) posted at
> >
> >       http://lkml.org/lkml/2007/2/12/88
> >
> > It implements a controller within the containers framework for limiting
> > memory usage (RSS usage).

> The key part of this patchset is the reclaim algorithm:
>
> Alas, I fear this might have quite bad worst-case behaviour.  One small
> container which is under constant memory pressure will churn the
> system-wide LRUs like mad, and will consume rather a lot of system time.
> So it's a point at which container A can deleteriously affect things which
> are running in other containers, which is exactly what we're supposed to
> not do.

Nice with a simple memory controller. The downside seems to be that it
doesn't scale very well when it comes to reclaim, but maybe that just
comes with being simple. Step by step, and maybe this is a good first
step?

Ideally I'd like to see unmapped pages handled on a per-container LRU
with a fallback to the system-wide LRUs. Shared/mapped pages could be
handled using PTE ageing/unmapping instead of page ageing, but that
may consume too much resources to be practical.

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
