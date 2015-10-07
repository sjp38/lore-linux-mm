Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id CB31F6B0254
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 11:45:03 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so24841263pab.3
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 08:45:03 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id pz3si58673332pbb.48.2015.10.07.08.45.02
        for <linux-mm@kvack.org>;
        Wed, 07 Oct 2015 08:45:03 -0700 (PDT)
Date: Wed, 7 Oct 2015 08:44:56 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151007154456.GJ26924@tassilo.jf.intel.com>
References: <20150930114255.13505.2618.stgit@canyon>
 <20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
 <20151002114118.75aae2f9@redhat.com>
 <20151002154039.69f82bdc@redhat.com>
 <20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
 <20151005212639.35932b6c@redhat.com>
 <20151005212045.GG26924@tassilo.jf.intel.com>
 <20151006010703.09e2f0ff@redhat.com>
 <20151007143120.7068416d@redhat.com>
 <20151007133619.GR12682@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151007133619.GR12682@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, netdev@vger.kernel.org

> There is a recent patch that may help here, see below, but maybe its
> just a matter of removing that :pp, as it ends with a /pp anyway, no
> need to state that twice :)

Yes the extra :pp was a regression in toplev. I fixed it now. Thanks.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
