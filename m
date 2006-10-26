Date: Thu, 26 Oct 2006 09:13:28 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 2/3] hugetlb: fix prio_tree unit
In-Reply-To: <20061026034739.GA6046@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0610260907390.6235@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0610250828020.8576@blonde.wat.veritas.com>
 <000001c6f890$373fb960$12d0180a@amr.corp.intel.com>
 <20061026034739.GA6046@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Gibson <david@gibson.dropbear.id.au>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Andrew Morton <akpm@osdl.org>, Bill Irwin <wli@holomorphy.com>, Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2006, David Gibson wrote:
> +
> +	/* This part of the test makes the problem more obvious, but
> +	 * is not essential.  It can't be done on powerpc, where
> +	 * segment restrictions prohibit us from performing such a
> +	 * mapping, so skip it there */
> +#if !defined(__powerpc__) && !defined(__powerpc64__)
> +	/* Replace middle hpage by tinypage mapping to trigger
> +	 * nr_ptes BUG */

I should add, I expect you'll need to extend that #if'ing to exclude
at least ia64 too, won't you?   No architecture that segregates its
hugepage virtual address space will manage the interposed tinypage.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
