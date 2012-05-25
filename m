Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6B3BF6B00ED
	for <linux-mm@kvack.org>; Fri, 25 May 2012 03:19:50 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so630818lbj.14
        for <linux-mm@kvack.org>; Fri, 25 May 2012 00:19:48 -0700 (PDT)
Date: Fri, 25 May 2012 10:19:45 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/2] vmevent: pass right attribute to
 vmevent_sample_attr()
In-Reply-To: <201205230928.39861.b.zolnierkie@samsung.com>
Message-ID: <alpine.LFD.2.02.1205251019091.3897@tux.localdomain>
References: <201205230928.39861.b.zolnierkie@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Cc: Anton Vorontsov <anton.vorontsov@linaro.org>, linux-mm@kvack.org

On Wed, 23 May 2012, Bartlomiej Zolnierkiewicz wrote:

> From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Subject: [PATCH] vmevent: pass right attribute to vmevent_sample_attr()
> 
> Pass "config attribute" (&watch->config->attrs[i]) not "sample
> attribute" (&watch->sample_attrs[i]) to vmevent_sample_attr() to
> allow use of the original attribute value in vmevent_attr_sample_fn().
> 
> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
> Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>

Looks good. I'm getting rejects for this. What tree did you use to 
generate the patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
