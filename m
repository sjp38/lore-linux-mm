Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id C04B88E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 17:16:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a23-v6so13326840pfo.23
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 14:16:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 16-v6si22171448pgy.641.2018.09.11.14.16.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Sep 2018 14:16:50 -0700 (PDT)
Date: Tue, 11 Sep 2018 14:16:45 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v9 PATCH 2/4] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180911211645.GA12159@bombadil.infradead.org>
References: <1536699493-69195-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536699493-69195-3-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536699493-69195-3-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2018 at 04:58:11AM +0800, Yang Shi wrote:
>  mm/mmap.c | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

I really think you're going about this the wrong way by duplicating
vm_munmap().
