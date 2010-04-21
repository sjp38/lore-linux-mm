Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 383476B01F7
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:24:31 -0400 (EDT)
Message-ID: <4BCF18A8.8080809@redhat.com>
Date: Wed, 21 Apr 2010 11:24:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] ksm: check for ERR_PTR from follow_page()
References: <20100421102759.GA29647@bicker>
In-Reply-To: <20100421102759.GA29647@bicker>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dan Carpenter <error27@gmail.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/21/2010 06:27 AM, Dan Carpenter wrote:
> The follow_page() function can potentially return -EFAULT so I added
> checks for this.
>
> Also I silenced an uninitialized variable warning on my version of gcc
> (version 4.3.2).
>
> Signed-off-by: Dan Carpenter<error27@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
