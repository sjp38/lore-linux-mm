Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5B15A6B0009
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 05:12:53 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o185so16706268pfb.1
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:12:53 -0800 (PST)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id q73si15994788pfq.209.2016.01.28.02.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 02:12:52 -0800 (PST)
Received: by mail-pf0-x234.google.com with SMTP id 65so21386799pfd.2
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 02:12:52 -0800 (PST)
Date: Thu, 28 Jan 2016 15:42:42 +0530
From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [PATCH] mm: polish virtual memory accounting
Message-ID: <20160128101242.GA16239@sudip-pc>
References: <145397434479.24456.7330581149702545550.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <145397434479.24456.7330581149702545550.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 28, 2016 at 12:45:44PM +0300, Konstantin Khlebnikov wrote:
> * add VM_STACK as alias for VM_GROWSUP/DOWN depending on architecture
> * always account VMAs with flag VM_STACK as stack (as it was before)
> * cleanup classifying helpers
> * update comments and documentation
> 
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> ---

With this blackfin defconfig build failure is fixed.

regards
sudip

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
