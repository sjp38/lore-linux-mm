Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 143AA6B02C3
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:11:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m5so141932133pfc.1
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:11:53 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i193si18797706pfe.242.2017.05.22.14.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:11:52 -0700 (PDT)
Date: Mon, 22 May 2017 14:11:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
Message-Id: <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
In-Reply-To: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 22 May 2017 16:47:42 +0530 Anshuman Khandual <khandual@linux.vnet.ibm.com> wrote:

> There are many places where we define size either left shifting integers
> or multiplying 1024s without any generic definition to fall back on. But
> there are couples of (powerpc and lz4) attempts to define these standard
> memory sizes. Lets move these definitions to core VM to make sure that
> all new usage come from these definitions eventually standardizing it
> across all places.

Grep further - there are many more definitions and some may now
generate warnings.

Newly including mm.h for these things seems a bit heavyweight.  I can't
immediately think of a more appropriate place.  Maybe printk.h or
kernel.h.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
