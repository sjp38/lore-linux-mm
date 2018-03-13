Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9169E6B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 18:00:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id c16so419265pgv.8
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 15:00:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 1-v6si801477plw.587.2018.03.13.15.00.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 15:00:47 -0700 (PDT)
Date: Tue, 13 Mar 2018 15:00:40 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 4/8] struct page: add field for vm_struct
Message-ID: <20180313220040.GA15791@bombadil.infradead.org>
References: <20180313214554.28521-1-igor.stoppa@huawei.com>
 <20180313214554.28521-5-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313214554.28521-5-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Tue, Mar 13, 2018 at 11:45:50PM +0200, Igor Stoppa wrote:
> When a page is used for virtual memory, it is often necessary to obtain
> a handler to the corresponding vm_struct, which refers to the virtually
> continuous area generated when invoking vmalloc.
> 
> The struct page has a "mapping" field, which can be re-used, to store a
> pointer to the parent area.
> 
> This will avoid more expensive searches, later on.
> 
> Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>

Regardless of the fate of the rest of this patchset, this makes sense
and we should have this.
