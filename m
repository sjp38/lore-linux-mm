Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4A072600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 08:20:53 -0500 (EST)
Date: Wed, 2 Dec 2009 14:20:48 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 24/24] HWPOISON: show corrupted file info
Message-ID: <20091202132048.GI18989@one.firstfloor.org>
References: <20091202031231.735876003@intel.com> <20091202043046.791112765@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202043046.791112765@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> +	dentry = d_find_alias(inode);
> +
> +	if (dentry) {
> +		spin_lock(&dentry->d_lock);
> +		name = dentry->d_name.name;
> +	}

The standard way to do that is d_path()
But the paths are somewhat meaningless without the root.

Better to not print path names for now.

And pgoff should be just a byte offset with a range

I'll skip this one for now.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
