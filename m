Date: Sat, 31 Mar 2007 13:00:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 2/2] i386 arch page size slab fixes
In-Reply-To: <20070331125536.a984e5ce.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0703311300010.1976@schroedinger.engr.sgi.com>
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
 <20070331193107.1800.28259.sendpatchset@schroedinger.engr.sgi.com>
 <20070331125536.a984e5ce.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

On Sat, 31 Mar 2007, Andrew Morton wrote:

> Can we disable SLUB on i386 in Kconfig until it gets sorted out?

Yes just do not apply this patch. The first one disables SLUB on i386.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
