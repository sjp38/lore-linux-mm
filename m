Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 720B46B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:03:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id s132so106870272ita.6
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 06:03:28 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id a14si4061404pgd.77.2017.08.14.06.03.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 06:03:27 -0700 (PDT)
Date: Mon, 14 Aug 2017 16:02:21 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/2] kmemleak: Delete an error message for a failed
 memory allocation in two functions
Message-ID: <20170814130220.q5w4fsbngphniqzc@mwanda>
References: <301bc8c9-d9f6-87be-ce1d-dc614e82b45b@users.sourceforge.net>
 <986426ab-4ca9-ee56-9712-d06c25a2ed1a@users.sourceforge.net>
 <20170814111430.lskrrg3fygpnyx6v@armageddon.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170814111430.lskrrg3fygpnyx6v@armageddon.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: SF Markus Elfring <elfring@users.sourceforge.net>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, kernel-janitors@vger.kernel.org

On Mon, Aug 14, 2017 at 12:14:32PM +0100, Catalin Marinas wrote:
> On Mon, Aug 14, 2017 at 11:35:02AM +0200, SF Markus Elfring wrote:
> > From: Markus Elfring <elfring@users.sourceforge.net>
> > Date: Mon, 14 Aug 2017 10:50:22 +0200
> > 
> > Omit an extra message for a memory allocation failure in these functions.
> > 
> > This issue was detected by using the Coccinelle software.
> > 
> > Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
> > ---
> >  mm/kmemleak.c | 5 +----
> >  1 file changed, 1 insertion(+), 4 deletions(-)
> > 
> > diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> > index 7780cd83a495..c6c798d90b2e 100644
> > --- a/mm/kmemleak.c
> > +++ b/mm/kmemleak.c
> > @@ -555,7 +555,6 @@ static struct kmemleak_object *create_object(unsigned long ptr, size_t size,
> >  
> >  	object = kmem_cache_alloc(object_cache, gfp_kmemleak_mask(gfp));
> >  	if (!object) {
> > -		pr_warn("Cannot allocate a kmemleak_object structure\n");
> >  		kmemleak_disable();
> 
> I don't really get what this patch is trying to achieve. Given that
> kmemleak will be disabled after this, I'd rather know why it happened.

kmem_cache_alloc() will generate a stack trace and a bunch of more
useful information if it fails.  The allocation isn't likely to fail,
but if it does you will know.  The extra message is just wasting RAM.

regards,
dan carpenter


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
