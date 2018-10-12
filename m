Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80CE06B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 16:59:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v88-v6so13235955pfk.19
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 13:59:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 12-v6si2338072pgq.337.2018.10.12.13.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 13:59:36 -0700 (PDT)
Date: Fri, 12 Oct 2018 13:59:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v7 1/6] mm: split SWP_FILE into SWP_ACTIVATED and SWP_FS
Message-Id: <20181012135934.b8dbbaaf8a01011ec21b5aba@linux-foundation.org>
In-Reply-To: <6d63d8668c4287a4f6d203d65696e96f80abdfc7.1536704650.git.osandov@fb.com>
References: <cover.1536704650.git.osandov@fb.com>
	<6d63d8668c4287a4f6d203d65696e96f80abdfc7.1536704650.git.osandov@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Omar Sandoval <osandov@osandov.com>
Cc: linux-btrfs@vger.kernel.org, kernel-team@fb.com, linux-mm@kvack.org

On Tue, 11 Sep 2018 15:34:44 -0700 Omar Sandoval <osandov@osandov.com> wrote:

> From: Omar Sandoval <osandov@fb.com>
> 
> The SWP_FILE flag serves two purposes: to make swap_{read,write}page()
> go through the filesystem, and to make swapoff() call
> ->swap_deactivate(). For Btrfs, we want the latter but not the former,
> so split this flag into two. This makes us always call
> ->swap_deactivate() if ->swap_activate() succeeded, not just if it
> didn't add any swap extents itself.
> 
> This also resolves the issue of the very misleading name of SWP_FILE,
> which is only used for swap files over NFS.
> 

Acked-by: Andrew Morton <akpm@linux-foundation.org>
