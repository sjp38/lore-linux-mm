Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0AAFD6B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 17:23:42 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so62312844pac.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 14:23:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pt2si28798014pbb.51.2015.05.13.14.23.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 14:23:41 -0700 (PDT)
Date: Wed, 13 May 2015 14:23:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] radix-tree: replace preallocated node array with linked
 list
Message-Id: <20150513142339.5f399c1feb795a83d392160d@linux-foundation.org>
In-Reply-To: <1431531414-173802-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1431531414-173802-1-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 13 May 2015 18:36:54 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> Currently we use per-cpu array to hold pointers to preallocated nodes.
> Let's replace it with linked list. On x86_64 it saves 256 bytes in
> per-cpu ELF section which may translate into freeing up 2MB of memory
> for NR_CPUS==8192.
> 

huh, so it's a non-NULL-terminated singly linked list.  Scary, but
it seems the right way to do it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
