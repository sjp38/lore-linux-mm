Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EFE016B006E
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 18:34:25 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so12349516pab.30
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 15:34:25 -0800 (PST)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id x4si22780029pda.9.2014.12.25.15.34.23
        for <linux-mm@kvack.org>;
        Thu, 25 Dec 2014 15:34:24 -0800 (PST)
Date: Thu, 25 Dec 2014 18:34:20 -0500 (EST)
Message-Id: <20141225.183420.2288499637535959481.davem@davemloft.net>
Subject: Re: [PATCH 33/38] sparc: drop pte_file()-related helpers
From: David Miller <davem@davemloft.net>
In-Reply-To: <1419423766-114457-34-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1419423766-114457-34-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill.shutemov@linux.intel.com
Cc: akpm@linux-foundation.org, peterz@infradead.org, mingo@kernel.org, davej@redhat.com, sasha.levin@oracle.com, hughd@google.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Wed, 24 Dec 2014 14:22:41 +0200

> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
> 
> This patch also increase number of bits availble for swap offset.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
