Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 6C91E6B13F2
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 10:04:33 -0500 (EST)
Date: Tue, 14 Feb 2012 09:04:30 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: warning if total alloc size overflow
In-Reply-To: <alpine.LFD.2.02.1202140929040.2721@tux.localdomain>
Message-ID: <alpine.DEB.2.00.1202140904040.20013@router.home>
References: <1329204499-2671-1-git-send-email-hamo.by@gmail.com> <alpine.LFD.2.02.1202140929040.2721@tux.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Yang Bai <hamo.by@gmail.com>, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue, 14 Feb 2012, Pekka Enberg wrote:

> Did you check how much kernel text size increases? I'm pretty sure we'd need
> to wrap this with CONFIG_SLAB_OVERFLOW ifdef.

Remove the inlining? This function is rarely called and not performance
critical.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
