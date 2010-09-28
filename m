Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F8FE6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 10:42:29 -0400 (EDT)
Date: Tue, 28 Sep 2010 09:43:03 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Slub cleanup5 1/3] slub: reduce differences between SMP and
 NUMA
In-Reply-To: <AANLkTim6rdHck7bVkQ1BdTf3Q1jf2WY6huDhTRQqqVBs@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1009280941230.6360@router.home>
References: <20100928131025.319846721@linux.com> <20100928131056.509118201@linux.com> <AANLkTim6rdHck7bVkQ1BdTf3Q1jf2WY6huDhTRQqqVBs@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Pekka Enberg wrote:

> On Tue, Sep 28, 2010 at 4:10 PM, Christoph Lameter <cl@linux.com> wrote:
> > Reduce the #ifdefs and simplify bootstrap by making SMP and NUMA as much alike
> > as possible. This means that there will be an additional indirection to get to
> > the kmem_cache_node field under SMP.
> >
> > Signed-off-by: Christoph Lameter <cl@linux.com>
>
> I'm slightly confused. What does SMP have to do with this? Isn't this
> simply NUMA vs UMA thing regardless whether its UP or SMP?

Right. But then UMA / UP is a rare config that I have only ever seen
working on IA64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
