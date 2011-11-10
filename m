Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5B1DB6B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 10:02:21 -0500 (EST)
Date: Thu, 10 Nov 2011 09:02:16 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm,x86,um: move CMPXCHG_DOUBLE config option
In-Reply-To: <1320933860-15588-4-git-send-email-heiko.carstens@de.ibm.com>
Message-ID: <alpine.DEB.2.00.1111100901590.19196@router.home>
References: <1320933860-15588-1-git-send-email-heiko.carstens@de.ibm.com> <1320933860-15588-4-git-send-email-heiko.carstens@de.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jeff Dike <jdike@addtoit.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 10 Nov 2011, Heiko Carstens wrote:

> Move CMPXCHG_DOUBLE and rename it to HAVE_CMPXCHG_DOUBLE so architectures can
> simply select the option if it is supported.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
