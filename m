Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id EA0836B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 14:18:21 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id jt11so11920940pbb.0
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 11:18:21 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ey5si30526464pab.45.2013.12.30.11.18.20
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 11:18:20 -0800 (PST)
Message-ID: <52C1C6F7.8010809@intel.com>
Date: Mon, 30 Dec 2013 11:18:15 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Fadvise: Directory level page cache cleaning support
References: <cover.1388409686.git.liwang@ubuntukylin.com>
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>

On 12/30/2013 05:45 AM, Li Wang wrote:
> This patch extends 'fadvise' to support directory level page cache
> cleaning. The call to posix_fadvise(fd, 0, 0, POSIX_FADV_DONTNEED) 
> with 'fd' referring to a directory will recursively reclaim page cache 
> entries of files inside 'fd'. For secruity concern, those inodes
> which the caller does not own appropriate permissions will not 
> be manipulated.

Why is this necessary to do in the kernel?  Why not leave it to
userspace to walk the filesystem(s)?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
