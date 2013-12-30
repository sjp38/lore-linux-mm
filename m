Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFD16B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 09:57:28 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id hq4so15725445wib.1
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 06:57:27 -0800 (PST)
Received: from mail.parisc-linux.org (palinux.external.hp.com. [192.25.206.14])
        by mx.google.com with ESMTPS id fp3si11885482wic.22.2013.12.30.06.57.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 30 Dec 2013 06:57:25 -0800 (PST)
Date: Mon, 30 Dec 2013 07:57:21 -0700
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 0/3] Fadvise: Directory level page cache cleaning
	support
Message-ID: <20131230145720.GB20793@parisc-linux.org>
References: <cover.1388409686.git.liwang@ubuntukylin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1388409686.git.liwang@ubuntukylin.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>

On Mon, Dec 30, 2013 at 09:45:15PM +0800, Li Wang wrote:
> VFS relies on LRU-like page cache eviction algorithm

Why is this a series of three patches?  It just seems like you're trying
to game the patch count statistics.  One patch would have been fine for
this tiny change.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
