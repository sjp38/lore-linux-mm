Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14A2F6B0003
	for <linux-mm@kvack.org>; Tue, 17 Jul 2018 17:37:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v9-v6so1141788pfn.6
        for <linux-mm@kvack.org>; Tue, 17 Jul 2018 14:37:54 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e7-v6si1756330pgc.233.2018.07.17.14.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Jul 2018 14:37:52 -0700 (PDT)
Date: Tue, 17 Jul 2018 14:37:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: disallow mapping that conflict for
 devm_memremap_pages()
Message-Id: <20180717143750.3cd7e77544d181a346212715@linux-foundation.org>
In-Reply-To: <152909478401.50143.312364396244072931.stgit@djiang5-desk3.ch.intel.com>
References: <152909478401.50143.312364396244072931.stgit@djiang5-desk3.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jiang <dave.jiang@intel.com>
Cc: linux-mm@kvack.org, dan.j.williams@intel.com, elliott@hpe.com, linux-nvdimm@lists.01.org

On Fri, 15 Jun 2018 13:33:39 -0700 Dave Jiang <dave.jiang@intel.com> wrote:

> When pmem namespaces created are smaller than section size, this can cause
> issue during removal and gpf was observed:
> 
> ...
>
> Add code to check whether we have mapping already in the same section and
> prevent additional mapping from created if that is the case.
> 

Which kernel version(s) do you believe need this fix, and why?
