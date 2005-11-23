Date: Tue, 22 Nov 2005 22:42:23 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH]: Free pages from local pcp lists under tight memory
 conditions
In-Reply-To: <20051122213612.4adef5d0.akpm@osdl.org>
Message-ID: <Pine.LNX.4.62.0511222238530.2084@graphe.net>
References: <20051122161000.A22430@unix-os.sc.intel.com>
 <20051122213612.4adef5d0.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Rohit Seth <rohit.seth@intel.com>, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Nov 2005, Andrew Morton wrote:

> +extern int drain_local_pages(void);

drain_cpu_pcps?

The naming scheme is a bit confusing right now. We drain the pcp 
structures not pages so maybe switch to pcp and then name each function so 
that the function can be distinguishes clearlyu?

> +static int drain_all_local_pages(void)

drain_all_pcps?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
