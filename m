Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 963046B016B
	for <linux-mm@kvack.org>; Mon, 22 Aug 2011 13:08:55 -0400 (EDT)
Date: Mon, 22 Aug 2011 19:09:16 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 3/4] string: introduce memchr_inv
Message-ID: <20110822170916.GZ26160@logfs.org>
References: <1314030548-21082-1-git-send-email-akinobu.mita@gmail.com> <1314030548-21082-4-git-send-email-akinobu.mita@gmail.com> <1314032270.32391.51.camel@jaguar>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1314032270.32391.51.camel@jaguar>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Akinobu Mita <akinobu.mita@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, logfs@logfs.org, Marcin Slusarz <marcin.slusarz@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, 22 August 2011 19:57:50 +0300, Pekka Enberg wrote:
> On Tue, 2011-08-23 at 01:29 +0900, Akinobu Mita wrote:
> > memchr_inv() is mainly used to check whether the whole buffer is filled
> > with just a specified byte.
> > 
> > The function name and prototype are stolen from logfs and the
> > implementation is from SLUB.
> > 
> > Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
> > Cc: Christoph Lameter <cl@linux-foundation.org>
> > Cc: Pekka Enberg <penberg@kernel.org>
> > Cc: Matt Mackall <mpm@selenic.com>
> > Cc: linux-mm@kvack.org
> > Cc: Joern Engel <joern@logfs.org>
> > Cc: logfs@logfs.org
> > Cc: Marcin Slusarz <marcin.slusarz@gmail.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Acked-by: Pekka Enberg <penberg@kernel.org>
Acked-by: Joern Engel <joern@logfs.org>

JA?rn

-- 
He who knows that enough is enough will always have enough.
-- Lao Tsu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
