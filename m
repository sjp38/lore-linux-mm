Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3A8F56007AD
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 17:45:43 -0500 (EST)
Date: Wed, 9 Dec 2009 22:45:36 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] export use_mm and unuse_mm for filesystem modules.
Message-ID: <20091209224536.GT14381@ZenIV.linux.org.uk>
References: <4B20277B.1030903@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B20277B.1030903@hp.com>
Sender: owner-linux-mm@kvack.org
To: jim owens <jowens@hp.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, mst@redhat.com, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 09, 2009 at 05:40:59PM -0500, jim owens wrote:
>
> required for btrfs directio worker threads.

Careful.  It's very easy to fsck up on biarch architectures with
that stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
