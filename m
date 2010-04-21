Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DDD336B01F2
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 19:44:37 -0400 (EDT)
Date: Thu, 22 Apr 2010 02:51:18 +0300
From: Izik Eidus <ieidus@redhat.com>
Subject: Re: [patch] ksm: check for ERR_PTR from follow_page()
Message-ID: <20100422025118.360ea4bc@redhat.com>
In-Reply-To: <20100421102759.GA29647@bicker>
References: <20100421102759.GA29647@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010 12:27:59 +0200
Dan Carpenter <error27@gmail.com> wrote:

Hello

> The follow_page() function can potentially return -EFAULT so I added 
> checks for this.
> 
> Also I silenced an uninitialized variable warning on my version of gcc 
> (version 4.3.2).
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> I'm not very familiar with this code, so handle with care.


Acked-by: Izik Eidus <ieidus@redhat.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
