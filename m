Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D253E8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:38:17 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id f2so5363765qtg.14
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:38:17 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p65si2323495qkf.138.2019.01.08.18.38.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:38:17 -0800 (PST)
Date: Tue, 8 Jan 2019 21:38:12 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V6 1/4] mm/cma: Add PF flag to force non cma alloc
Message-ID: <20190109023812.GF20586@redhat.com>
References: <20190108045110.28597-1-aneesh.kumar@linux.ibm.com>
 <20190108045110.28597-2-aneesh.kumar@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190108045110.28597-2-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@kernel.org>, Alexey Kardashevskiy <aik@ozlabs.ru>, David Gibson <david@gibson.dropbear.id.au>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jan 08, 2019 at 10:21:07AM +0530, Aneesh Kumar K.V wrote:
> This patch add PF_MEMALLOC_NOCMA which make sure any allocation in that context
> is marked non movable and hence cannot be satisfied by CMA region.
> 
> This is useful with get_user_pages_cma_migrate where we take a page pin by
> migrating pages from CMA region. Marking the section PF_MEMALLOC_NOCMA ensures
> that we avoid uncessary page migration later.
> 
> Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
