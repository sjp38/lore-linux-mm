Date: Fri, 17 Dec 2004 08:27:58 -0800 (PST)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
In-Reply-To: <20041217061150.GF12049@wotan.suse.de>
Message-ID: <Pine.LNX.4.58.0412170827280.17806@server.graphe.net>
References: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com>
 <20041217061150.GF12049@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 Dec 2004, Andi Kleen wrote:

> struct page {
>         page_flags_t flags;             /* Atomic flags, some possibly
>                                          * updated asynchronously */
>
> 			<------------ what to do with the 4 byte padding here?
>

Put the order of the page there for compound pages instead of having that
in index?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
