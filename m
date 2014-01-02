Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8CDF96B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 13:35:11 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id y10so14514339pdj.9
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 10:35:11 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ez5si43358205pab.19.2014.01.02.10.35.09
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 10:35:10 -0800 (PST)
Message-ID: <52C5B158.10109@intel.com>
Date: Thu, 02 Jan 2014 10:35:04 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] Fadvise: Directory level page cache cleaning support
References: <cover.1388409686.git.liwang@ubuntukylin.com> <52C1C6F7.8010809@intel.com> <FFE7C704-791E-4B73-9251-EFB9135AB254@dilger.ca> <52C1E6B1.4010402@intel.com> <52C55F12.4050406@ubuntukylin.com>
In-Reply-To: <52C55F12.4050406@ubuntukylin.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>, Andreas Dilger <adilger@dilger.ca>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Zefan Li <lizefan@huawei.com>, Matthew Wilcox <matthew@wil.cx>

On 01/02/2014 04:44 AM, Li Wang wrote:
> Do we really need clean dcache/icache at the current stage?
> That will introduce more code work, so far, iput() will put
> those unreferenced inodes into superblock lru list. To free
> the inodes inside a specific directory, it seems we do not
> have a handy API to use, and need
> modify iput() to recognize our situation, and collect those
> inodes into our list rather than superblock lru list. Maybe
> we stay at current stage now, since it is simple and could
> gain the major benefits, leave the dcache/icache cleaning
> to do in the future?

<sigh> top posting....

I read your response as "that's the right thing to do, but it's too much
work".  Fair enough.  But if we're going to take the lazy hack approach
here, maybe we should do this through some other interface than a
syscall where we're stuck with the behavior.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
