Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD0D06B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 19:01:27 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id 203so31465843ith.3
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 16:01:27 -0800 (PST)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [69.252.207.37])
        by mx.google.com with ESMTPS id n5si1780783iof.45.2017.01.18.16.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 16:01:27 -0800 (PST)
Date: Wed, 18 Jan 2017 18:00:24 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC] mm: Rename SLAB_DESTROY_BY_RCU to
 SLAB_TYPESAFE_BY_RCU
In-Reply-To: <20170118221737.GP5238@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.20.1701181758030.27439@east.gentwo.org>
References: <20170118110731.GA15949@linux.vnet.ibm.com> <20170118111201.GB29472@bombadil.infradead.org> <20170118221737.GP5238@linux.vnet.ibm.com>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: willy@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org

On Wed, 18 Jan 2017, Paul E. McKenney wrote:

> Actually, slab is using RCU to provide type safety to those slab users
> who request it.

Typesafety is a side effect. The main idea here is that the object can
still be accessed in RCU sections after another processor frees the
object. We guarantee that the object is not freed but it may be reused
for another object within the RCU period.

Can we have a name that expresses all of that properly?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
