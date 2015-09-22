Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0005B6B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:34:52 -0400 (EDT)
Received: by qgx61 with SMTP id 61so2496022qgx.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 12:34:52 -0700 (PDT)
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com. [129.33.205.209])
        by mx.google.com with ESMTPS id p91si3074847qkp.57.2015.09.22.12.34.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 22 Sep 2015 12:34:52 -0700 (PDT)
Received: from /spool/local
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 22 Sep 2015 15:34:51 -0400
Received: from b01cxnp23032.gho.pok.ibm.com (b01cxnp23032.gho.pok.ibm.com [9.57.198.27])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D0F48C9003C
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:25:50 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23032.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8MJYlD610747962
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 19:34:47 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8MJYkL3002202
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 15:34:47 -0400
Date: Wed, 23 Sep 2015 01:06:20 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH V2  2/2] powerpc:numa Do not allocate bootmem memory for
 non existing nodes
Message-ID: <20150922193620.GA6942@linux.vnet.ibm.com>
Reply-To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
References: <1442282917-16893-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <1442282917-16893-3-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <1442899743.18408.5.camel@ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1442899743.18408.5.camel@ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, anton@samba.org, akpm@linux-foundation.org, nacc@linux.vnet.ibm.com, gkurz@linux.vnet.ibm.com, grant.likely@linaro.org, nikunj@linux.vnet.ibm.com, vdavydov@parallels.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

* Michael Ellerman <mpe@ellerman.id.au> [2015-09-22 15:29:03]:

> On Tue, 2015-09-15 at 07:38 +0530, Raghavendra K T wrote:
> >
> > ... nothing
> 
> Sure this patch looks obvious, but please give me a changelog that proves
> you've thought about it thoroughly.
> 
> For example is it OK to use for_each_node() at this point in boot? Is there any
> historical reason why we did it with a hard coded loop? If so what has changed.
> What systems have you tested on? etc. etc.
> 
> cheers

Hi Michael,
resending the patches with the changelog.

Please note that the patch is in -mm tree already.

---8<---
