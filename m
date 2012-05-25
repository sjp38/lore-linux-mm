Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id F07ED6B00F7
	for <linux-mm@kvack.org>; Fri, 25 May 2012 05:11:12 -0400 (EDT)
Received: by lahi5 with SMTP id i5so709355lah.14
        for <linux-mm@kvack.org>; Fri, 25 May 2012 02:11:10 -0700 (PDT)
Date: Fri, 25 May 2012 12:11:07 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/2] vmevent: pass right attribute to
 vmevent_sample_attr()
In-Reply-To: <201205251015.06924.b.zolnierkie@samsung.com>
Message-ID: <alpine.LFD.2.02.1205251209330.7552@tux.localdomain>
References: <201205230928.39861.b.zolnierkie@samsung.com> <alpine.LFD.2.02.1205251019091.3897@tux.localdomain> <201205251015.06924.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, linux-mm@kvack.org

On Fri, 25 May 2012, Bartlomiej Zolnierkiewicz wrote:
> > Looks good. I'm getting rejects for this. What tree did you use to 
> > generate the patch?
> 
> Ah, sorry for that.  I generated this patch with Anton's "vmevent: Implement
> special low-memory attribute" patch applied..  Here is a version against
> vanilla vmevent-core:

Right. I think Anton is reworking his patch which is why it's not merged 
to vmevent/core.

I applied your patch, thanks!

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
