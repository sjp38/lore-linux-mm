Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 7927E6B0044
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 09:47:19 -0400 (EDT)
Date: Tue, 16 Oct 2012 13:47:18 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] SLUB: remove hard coded magic numbers from
 resiliency_test
In-Reply-To: <alpine.DEB.2.00.1210151753060.31712@chino.kir.corp.google.com>
Message-ID: <0000013a69d41636-b42ca340-7e04-431d-86ca-f38610bfaaf8-000000@email.amazonses.com>
References: <1350145885-6099-1-git-send-email-richard@rsk.demon.co.uk> <1350145885-6099-2-git-send-email-richard@rsk.demon.co.uk> <0000013a66294083-76b27acc-ede7-45d7-849a-0932adecac14-000000@email.amazonses.com>
 <alpine.DEB.2.00.1210151753060.31712@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Richard Kennedy <richard@rsk.demon.co.uk>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 15 Oct 2012, David Rientjes wrote:

> On Mon, 15 Oct 2012, Christoph Lameter wrote:
>
> > > Use the always inlined function kmalloc_index to translate
> > > sizes to indexes, so that we don't have to have the slab indexes
> > > hard coded in two places.
> >
> > Acked-by: Christoph Lameter <cl@linux.com>
> >
>
> Shouldn't this be using get_slab() instead?

Right that would even be better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
