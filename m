Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDA76B000A
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:52:51 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id i64-v6so2196390ita.8
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:52:51 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id o76-v6si7585593ith.18.2018.03.23.08.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 08:52:50 -0700 (PDT)
Date: Fri, 23 Mar 2018 10:52:48 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab_common: remove test if cache name is accessible
In-Reply-To: <alpine.LRH.2.02.1803231133310.22626@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803231052220.5289@nuc-kabylake>
References: <alpine.LRH.2.02.1803231133310.22626@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 23 Mar 2018, Mikulas Patocka wrote:

> Since the commit db265eca7700 ("mm/sl[aou]b: Move duping of slab name to
> slab_common.c"), the kernel always duplicates the slab cache name when
> creating a slab cache, so the test if the slab name is accessible is
> useless.

Acked-by: Christoph Lameter <cl@linux.com>
