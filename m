Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1FB0C6B0023
	for <linux-mm@kvack.org>; Wed, 14 Sep 2011 15:29:49 -0400 (EDT)
Date: Wed, 14 Sep 2011 12:27:44 -0700
From: Kees Cook <kees@ubuntu.com>
Subject: Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
Message-ID: <20110914192744.GC4529@outflux.net>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110910164134.GA2442@albatros>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Vasiliy,

On Sat, Sep 10, 2011 at 08:41:34PM +0400, Vasiliy Kulikov wrote:
> Historically /proc/slabinfo has 0444 permissions and is accessible to
> the world.  slabinfo contains rather private information related both to
> the kernel and userspace tasks.  Depending on the situation, it might
> reveal either private information per se or information useful to make
> another targeted attack.  Some examples of what can be learned by
> reading/watching for /proc/slabinfo entries:
> ...
> World readable slabinfo simplifies kernel developers' job of debugging
> kernel bugs (e.g. memleaks), but I believe it does more harm than
> benefits.  For most users 0444 slabinfo is an unreasonable attack vector.
> 
> Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

Haven't had any mass complaints about the 0400 in Ubuntu (sorry Dave!), so
I'm obviously for it.

Reviewed-by: Kees Cook <kees@ubuntu.com>

-Kees

-- 
Kees Cook
Ubuntu Security Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
