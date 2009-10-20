Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 881386B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 03:28:28 -0400 (EDT)
Date: Tue, 20 Oct 2009 15:28:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] rmap : move the `out` to a more proper place
Message-ID: <20091020072819.GA4224@localhost>
References: <1256022859-23849-1-git-send-email-shijie8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1256022859-23849-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Huang Shijie <shijie8@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 20, 2009 at 03:14:19PM +0800, Huang Shijie wrote:
> When the code jumps to the `out' ,the referenced is still zero.
> So there is no need to check it.
> 
> Signed-off-by: Huang Shijie <shijie8@gmail.com>

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
