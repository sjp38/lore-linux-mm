Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id B79BA6B0037
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 10:29:56 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so4600966pdb.28
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 07:29:56 -0700 (PDT)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id ht9si19939020pdb.219.2014.09.24.07.29.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 24 Sep 2014 07:29:55 -0700 (PDT)
Date: Wed, 24 Sep 2014 09:29:53 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: initialize object alignment on cache
 creation
In-Reply-To: <alpine.DEB.2.02.1409231710430.8339@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.11.1409240929240.6334@gentwo.org>
References: <20140923141940.e2d3840f31d0f8850b925cf6@linux-foundation.org> <alpine.DEB.2.02.1409231439190.22630@chino.kir.corp.google.com> <alpine.DEB.2.11.1409231821050.32451@gentwo.org> <alpine.DEB.2.02.1409231710430.8339@chino.kir.corp.google.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, a.elovikov@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 23 Sep 2014, David Rientjes wrote:

> Previous to commit 4590685546a3 ("mm/sl[aou]b: Common alignment code")
> which introduced this issue.

Ah. Ok. I see and approve.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
