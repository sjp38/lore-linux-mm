Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C129C6B06F2
	for <linux-mm@kvack.org>; Sat, 12 May 2018 10:25:01 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z5-v6so5869159pfz.6
        for <linux-mm@kvack.org>; Sat, 12 May 2018 07:25:01 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i62-v6si5706384pfg.218.2018.05.12.07.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 12 May 2018 07:25:00 -0700 (PDT)
Date: Sat, 12 May 2018 07:24:51 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3] mm: Change return type to vm_fault_t
Message-ID: <20180512142451.GB24215@bombadil.infradead.org>
References: <20180512061712.GA26660@jordon-HP-15-Notebook-PC>
 <e194731158f7f89145ed0ae28f46aac5726fc32d.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e194731158f7f89145ed0ae28f46aac5726fc32d.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com, dan.j.williams@intel.com, rientjes@google.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, May 11, 2018 at 11:20:29PM -0700, Joe Perches wrote:
> It'd be nicer to realign the 2nd and 3rd arguments
> on the subsequent lines.
> 
> 	vm_fault_t (*fault)(const struct vm_special_mapping *sm,
> 			    struct vm_area_struct *vma,
> 			    struct vm_fault *vmf);
> 

It'd be nicer if people didn't try to line up arguments at all and
just indented by an extra two tabs when they had to break a logical
line due to the 80-column limit.
