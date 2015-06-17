Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 192D76B0032
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 02:29:12 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so21408192qkh.0
        for <linux-mm@kvack.org>; Tue, 16 Jun 2015 23:29:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h4si3433284qge.80.2015.06.16.23.29.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jun 2015 23:29:11 -0700 (PDT)
Date: Wed, 17 Jun 2015 08:29:05 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 6/7] slub: improve bulk alloc strategy
Message-ID: <20150617082905.54fc0094@redhat.com>
In-Reply-To: <20150616145336.1cacbfb88ff55b0e088676c3@linux-foundation.org>
References: <20150615155053.18824.617.stgit@devil>
	<20150615155246.18824.3788.stgit@devil>
	<20150616145336.1cacbfb88ff55b0e088676c3@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, netdev@vger.kernel.org, Alexander Duyck <alexander.duyck@gmail.com>, brouer@redhat.com

On Tue, 16 Jun 2015 14:53:36 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 15 Jun 2015 17:52:46 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
[...]
> > +			/* Invoke slow path one time, then retry fastpath
> > +			 * as side-effect have updated c->freelist
> > +			 */
> 
> That isn't very grammatical.
> 
> Block comments are formatted
> 
> 	/*
> 	 * like this
> 	 */
> 
> please.

Sure, old habit, this comment style is just that we use in net/ tree.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
