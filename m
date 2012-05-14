Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5A8E96B00E7
	for <linux-mm@kvack.org>; Sun, 13 May 2012 21:08:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7816278pbb.14
        for <linux-mm@kvack.org>; Sun, 13 May 2012 18:08:49 -0700 (PDT)
Date: Mon, 14 May 2012 09:09:32 +0800
From: "majianpeng" <majianpeng@gmail.com>
References: <201205111008157652383@gmail.com>,
 <alpine.DEB.2.00.1205111113460.31049@router.home>
Subject: Re: Re: [PATCH] slub: missing test for partial pages flush work in flush_all
Message-ID: <201205140909294844918@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, Christoph Lameter <cl@linux.com>
Cc: linux-mm <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>


On Fri, May 11, 2012 at 7:14 PM, Christoph Lameter <cl@linux.com> wrote:
> Didn't I already ack this before?
>
> Acked-by: Christoph Lameter <cl@linux.com>
>

>Yes, you did, but the patch description and title was lacking and
>Majianpeng kindly fixed it, hence the re-send, I guess.

>I've added Andrew, since he took my original commit that introduces
>the bug that this patch by Majianpeng  fixes (and also LKML).

>This fix really needs to get into 3.4, otherwise we'll be breaking
>slub. What's the best way to go about that?

>Thanks!
>Gilad


Sorry for late to relay. I rewrited the comment and resend.
I have a question to ask:because the patch fixed by others,for example Christoph Lameter, Gilad.
Should I add sogine-off by them in the patch?
																	Thanks all!

------------------				 
majianpeng
2012-05-14


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
