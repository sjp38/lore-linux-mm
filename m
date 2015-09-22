Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id 52A2C6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 05:09:45 -0400 (EDT)
Received: by lahg1 with SMTP id g1so4405479lah.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:09:44 -0700 (PDT)
Received: from mail-la0-x230.google.com (mail-la0-x230.google.com. [2a00:1450:4010:c03::230])
        by mx.google.com with ESMTPS id as1si18572775lbc.94.2015.09.22.02.09.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 02:09:43 -0700 (PDT)
Received: by lahg1 with SMTP id g1so4404993lah.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:09:43 -0700 (PDT)
Date: Tue, 22 Sep 2015 12:09:35 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 1/2] mm: add architecture primitives for software dirty
 bit clearing
Message-ID: <20150922090935.GA10131@uranus>
References: <1442848940-22108-1-git-send-email-schwidefsky@de.ibm.com>
 <1442848940-22108-2-git-send-email-schwidefsky@de.ibm.com>
 <20150921194854.GD3181@uranus>
 <20150922093549.504a5fb3@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150922093549.504a5fb3@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@linuxfoundation.org>, Pavel Emelyanov <xemul@virtuozzo.com>

On Tue, Sep 22, 2015 at 09:35:49AM +0200, Martin Schwidefsky wrote:
> > 
> > Looks good to me. Thank you, Martin!
> > (I cant ack s390 part 'casuse I simply not familiar
> >  with the architecture).
> 
> Sure, the s390 patch just shows why the new arch functions are needed..

A see, thanks!

> 
> > Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>
> 
> Thanks. I have added both patches to the features branch of linux-s390
> for the 4.4 merge window.

The first patch (x86 and general helpers) seems better to go via
Andrew (CC'ed) becase they are not s390 only. And while these
changes are fine for me and you as far as I can say, lets them
floating around for some more review just to make sure we're not
missing something obvious.

And initially the soft-dirty feature has been hittin vanilla by
-mm tree so I suppose we should continue this way, though I
don't mind if it gonna be merged via pull request from s390
side but still ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
