Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 094176B007B
	for <linux-mm@kvack.org>; Sun, 17 May 2015 08:38:54 -0400 (EDT)
Received: by wizk4 with SMTP id k4so46582860wiz.1
        for <linux-mm@kvack.org>; Sun, 17 May 2015 05:38:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cp11si9723320wjb.135.2015.05.17.05.38.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 May 2015 05:38:52 -0700 (PDT)
Date: Sun, 17 May 2015 08:38:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] radix-tree: replace preallocated node array with linked
 list
Message-ID: <20150517123839.GA5575@cmpxchg.org>
References: <1431531414-173802-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431531414-173802-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, May 13, 2015 at 06:36:54PM +0300, Kirill A. Shutemov wrote:
> Currently we use per-cpu array to hold pointers to preallocated nodes.
> Let's replace it with linked list. On x86_64 it saves 256 bytes in
> per-cpu ELF section which may translate into freeing up 2MB of memory
> for NR_CPUS==8192.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
