Date: Tue, 13 May 2003 15:21:41 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC][PATCH] Interface to invalidate regions of mmaps
Message-Id: <20030513152141.5ab69f07.akpm@digeo.com>
In-Reply-To: <20030513133636.C2929@us.ibm.com>
References: <20030513133636.C2929@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: paulmck@us.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

"Paul E. McKenney" <paulmck@us.ibm.com> wrote:
>
> This patch adds an API to allow networked and distributed filesystems
> to invalidate portions of (or all of) a file.  This is needed to 
> provide POSIX or near-POSIX semantics in such filesystems, as
> discussed on LKML late last year:
> 
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=103609089604576&w=2
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=103167761917669&w=2
> 
> Thoughts?

What filesystems would be needing this, and when could we see live code
which actually uses it?

> +/*
> + * Helper function for invalidate_mmap_range().
> + * Both hba and hlen are page numbers in PAGE_SIZE units.
> + */
> +static void 
> +invalidate_mmap_range_list(struct list_head *head,
> +			   unsigned long const hba,
> +			   unsigned long const hlen)

Be nice to consolidate this with vmtruncate_list, so that it gets
exercised.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
