Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 60BB06B0012
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 02:59:03 -0400 (EDT)
Date: Mon, 20 Jun 2011 08:59:08 +0200
From: Daniel =?iso-8859-1?Q?Gl=F6ckner?= <daniel-gl@gmx.net>
Subject: [PATCH] nommu: reimplement remap_pfn_range() to simply return 0
Message-ID: <20110620065907.GA29075@minime.bse>
References: <1308547333-27413-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308547333-27413-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, gerg@snapgear.com, dhowells@redhat.com, lethal@linux-sh.org, gerg@uclinux.org, walken@google.com, uclinux-dist-devel@blackfin.uclinux.org, geert@linux-m68k.org

On Mon, Jun 20, 2011 at 01:22:13PM +0800, Bob Liu wrote:
> Function remap_pfn_range() means map physical address pfn<<PAGE_SHIFT to
> user addr.
> 
> For nommu arch it's implemented by vma->vm_start = pfn << PAGE_SHIFT which is
> wrong acroding the original meaning of this function.
> 
> Some driver developer using remap_pfn_range() with correct parameter will get
> unexpected result because vm_start is changed.
> 
> It should be implementd just like addr = pfn << PAGE_SHIFT which is meanless
> on nommu arch, so this patch just make it simply return 0.

I'd return -EINVAL if addr != pfn << PAGE_SHIFT.
And I can imagine architectures wanting to do something with the prot flags.

  Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
