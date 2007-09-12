Date: Wed, 12 Sep 2007 16:54:43 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 02 of 24] avoid oom deadlock in nfs_create_request
In-Reply-To: <90afd499e8ca0dfd2e02.1187786929@v2.random>
Message-ID: <Pine.LNX.4.64.0709121652360.4489@schroedinger.engr.sgi.com>
References: <90afd499e8ca0dfd2e02.1187786929@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 22 Aug 2007, Andrea Arcangeli wrote:

> +	/* try to allocate the request struct */
> +	req = nfs_page_alloc();
> +	if (unlikely(!req)) {
> +		/*
> +		 * -ENOMEM will be returned only when TIF_MEMDIE is set
> +		 * so userland shouldn't risk to get confused by a new
> +		 * unhandled ENOMEM errno.
> +		 */
> +		WARN_ON(!test_thread_flag(TIF_MEMDIE));
> +		return ERR_PTR(-ENOMEM);

The comment does not match what is actually occurring. We unconditionally
return -ENOMEM. Debug leftover?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
