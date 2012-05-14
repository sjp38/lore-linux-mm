Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 5EAD56B00EB
	for <linux-mm@kvack.org>; Mon, 14 May 2012 09:45:08 -0400 (EDT)
Date: Mon, 14 May 2012 08:45:05 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Re: [PATCH] slub: missing test for partial pages flush work in
 flush_all
In-Reply-To: <201205140909294844918@gmail.com>
Message-ID: <alpine.DEB.2.00.1205140844490.26056@router.home>
References: <201205111008157652383@gmail.com>, <alpine.DEB.2.00.1205111113460.31049@router.home> <201205140909294844918@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 14 May 2012, majianpeng wrote:

> Sorry for late to relay. I rewrited the comment and resend.
> I have a question to ask:because the patch fixed by others,for example Christoph Lameter, Gilad.
> Should I add sogine-off by them in the patch?

I 6hink its fine the way it is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
