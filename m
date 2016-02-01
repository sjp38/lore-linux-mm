Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E74C6B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 09:34:49 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p63so74106367wmp.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 06:34:49 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f70si7890079wmd.99.2016.02.01.06.34.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 06:34:48 -0800 (PST)
Date: Mon, 1 Feb 2016 15:34:32 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 3/5] btrfs: Use radix_tree_iter_retry()
Message-ID: <20160201143432.GH31992@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <1453929472-25566-1-git-send-email-matthew.r.wilcox@intel.com>
 <1453929472-25566-4-git-send-email-matthew.r.wilcox@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1453929472-25566-4-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@linux.intel.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 27, 2016 at 04:17:50PM -0500, Matthew Wilcox wrote:
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> Even though this is a 'can't happen' situation, use the new
> radix_tree_iter_retry() pattern to eliminate a goto.

Andrew's tree contains a fixup for a build failure

> @@ -147,7 +146,7 @@ restart:
>  		/* Shouldn't happen but that kind of thinking creates CVE's */
>  		if (radix_tree_exception(eb)) {
>  			if (radix_tree_deref_retry(eb))
> -				goto restart;
> +				slot = radix_tree_iter_retry(iter);

				slot = radix_tree_iter_retry(&iter);

http://ozlabs.org/~akpm/mmots/broken-out/btrfs-use-radix_tree_iter_retry-fix.patch

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
