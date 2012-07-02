Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 08D7D6B0069
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:56:08 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so9552996lbj.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 03:56:07 -0700 (PDT)
Date: Mon, 2 Jul 2012 13:56:03 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slab: do not call compound_head() in page_get_cache()
In-Reply-To: <alpine.DEB.2.00.1206201837320.7850@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1207021355211.1916@tux.localdomain>
References: <1340233273-10994-1-git-send-email-walken@google.com> <alpine.DEB.2.00.1206201837320.7850@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 20 Jun 2012, David Rientjes wrote:

> On Wed, 20 Jun 2012, Michel Lespinasse wrote:
> 
> > page_get_cache() does not need to call compound_head(), as its unique
> > caller virt_to_slab() already makes sure to return a head page.
> > 
> > Additionally, removing the compound_head() call makes page_get_cache()
> > consistent with page_get_slab().
> > 
> > Signed-off-by: Michel Lespinasse <walken@google.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

The page_get_cache() helper is no longer used in the slab/next branch of

  git://github.com/penberg/linux.git

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
