Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8423E6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 10:34:00 -0400 (EDT)
Received: by yxk8 with SMTP id 8so2795180yxk.14
        for <linux-mm@kvack.org>; Tue, 28 Sep 2010 07:34:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100928131056.509118201@linux.com>
References: <20100928131025.319846721@linux.com>
	<20100928131056.509118201@linux.com>
Date: Tue, 28 Sep 2010 17:34:30 +0300
Message-ID: <AANLkTim6rdHck7bVkQ1BdTf3Q1jf2WY6huDhTRQqqVBs@mail.gmail.com>
Subject: Re: [Slub cleanup5 1/3] slub: reduce differences between SMP and NUMA
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 28, 2010 at 4:10 PM, Christoph Lameter <cl@linux.com> wrote:
> Reduce the #ifdefs and simplify bootstrap by making SMP and NUMA as much alike
> as possible. This means that there will be an additional indirection to get to
> the kmem_cache_node field under SMP.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

I'm slightly confused. What does SMP have to do with this? Isn't this
simply NUMA vs UMA thing regardless whether its UP or SMP?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
