Date: Thu, 24 Jan 2008 15:41:51 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [kvm-devel] [PATCH] export notifier #1
Message-ID: <20080124144150.GO7141@v2.random>
References: <20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com> <20080122144332.GE7331@v2.random> <20080122200858.GB15848@v2.random> <Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com> <20080122223139.GD15848@v2.random> <Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com> <20080123114136.GE15848@v2.random> <Pine.LNX.4.64.0801231149150.13547@schroedinger.engr.sgi.com> <20080124143454.GN7141@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080124143454.GN7141@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 24, 2008 at 03:34:54PM +0100, Andrea Arcangeli wrote:
> set_page_dirty can be called inside ->invalidate_page if needed. But
> I'm not against artificially setting the dirty bit of the pteval
> returned by set_page_dirty, perhaps that's more efficient as it will
              ^^^^^^^^^^^^^^ ptep_clear_flush of course

> require a single locked op on the page_t.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
