Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7AA1960021B
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 13:25:34 -0500 (EST)
Date: Wed, 9 Dec 2009 12:24:55 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] mm/vmalloc: don't use vmalloc_end
In-Reply-To: <alpine.DEB.2.00.0912091218060.16491@router.home>
Message-ID: <alpine.DEB.2.00.0912091224061.16491@router.home>
References: <4B1D3A3302000078000241CD@vpn.id2.novell.com> <20091207153552.0fadf335.akpm@linux-foundation.org> <4B1E1B1B0200007800024345@vpn.id2.novell.com> <alpine.DEB.2.00.0912091128280.16491@router.home> <4B1FE81F.30408@sgi.com>
 <alpine.DEB.2.00.0912091218060.16491@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mike Travis <travis@sgi.com>
Cc: tony.luck@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Beulich <JBeulich@novell.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Geert Uytterhoeven <geert@linux-m68k.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 2009, Christoph Lameter wrote:

> Boot with 2.6.32 and see if the per cpu allocator works. Check if there
> are any changes to memory consumption. Create a few thousand virtual
> ethernet devices and see if the system keels over.

Argh. You have to wait till 2.6.33-rc1 I believe to get the conversion of
the SNMP MIBs for the new per cpu allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
