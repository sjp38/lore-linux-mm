Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id F07076B0008
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 11:48:48 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id 72so10599326iod.16
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 08:48:48 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id o76-v6si7585593ith.18.2018.03.23.08.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 08:48:47 -0700 (PDT)
Date: Fri, 23 Mar 2018 10:48:46 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: introduce the flag SLAB_MINIMIZE_WASTE
In-Reply-To: <alpine.LRH.2.02.1803231113410.22626@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.20.1803231047290.5238@nuc-kabylake>
References: <alpine.LRH.2.02.1803200954590.18995@file01.intranet.prod.int.rdu2.redhat.com> <alpine.LRH.2.02.1803201510030.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803201536590.28319@nuc-kabylake>
 <alpine.LRH.2.02.1803201740280.21066@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211024220.2175@nuc-kabylake> <alpine.LRH.2.02.1803211153320.16017@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211226350.3174@nuc-kabylake>
 <alpine.LRH.2.02.1803211425330.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211354170.13978@nuc-kabylake> <alpine.LRH.2.02.1803211500570.26409@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803211508560.17257@nuc-kabylake>
 <alpine.LRH.2.02.1803211613010.28365@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.20.1803230956420.4108@nuc-kabylake> <alpine.LRH.2.02.1803231113410.22626@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mike Snitzer <msnitzer@redhat.com>

On Fri, 23 Mar 2018, Mikulas Patocka wrote:

> This test isn't locked against anything, so it may race with concurrent
> allocation. "any_slab_objects" may return false and a new object in the
> slab cache may appear immediatelly after that.

Ok the same reasoning applies to numerous other slab configuration
settings in /sys/kernel/slab.... So we need to disable all of that or come
up with a sane way of synchronization.
