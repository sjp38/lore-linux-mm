Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4106B00FC
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 14:22:04 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id q10so10572750pdj.41
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 11:22:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.139])
        by mx.google.com with SMTP id n5si197091pav.69.2013.11.06.11.22.01
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 11:22:02 -0800 (PST)
Date: Wed, 6 Nov 2013 20:21:54 +0100
From: Andreas Herrmann <andreas.herrmann@calxeda.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
Message-ID: <20131106192154.GG5661@alberich>
References: <20131106184529.GB5661@alberich>
 <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Nov 06, 2013 at 02:16:33PM -0500, Christoph Lameter wrote:
> On Wed, 6 Nov 2013, Andreas Herrmann wrote:
> 
> > When I've used slub_debug kernel option (e.g.
> > "slub_debug=,skbuff_fclone_cache" or similar) on a debug session I've
> > seen a panic like:
> 
> Hmmm.. That looks like its due to some slabs not having names
> during early boot. kmem_cache_flags is called with NULL as a parameter.
> 
> Are you sure that this fixes the issue?

?

Sure, of course I've tested my patch as I required slub debugging.
Panic was gone and debugging of the selected slab enabled.


Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
