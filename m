Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B48376B0169
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 12:57:54 -0400 (EDT)
Subject: Re: [PATCH 3/4] string: introduce memchr_inv
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com>
	 <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 22 Aug 2011 19:57:50 +0300
Message-ID: <1314032270.32391.51.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Akinobu Mita <akinobu.mita@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Joern Engel <joern@logfs.org>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, 2011-08-23 at 01:29 +0900, Akinobu Mita wrote:
> memchr_inv() is mainly used to check whether the whole buffer is filled
> with just a specified byte.
> 
> The function name and prototype are stolen from logfs and the
> implementation is from SLUB.
> 
> Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: linux-mm@kvack.org
> Cc: Joern Engel <joern@logfs.org>
> Cc: logfs@logfs.org
> Cc: Marcin Slusarz <marcin.slusarz@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
