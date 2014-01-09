Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7CE256B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:32:08 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so2681372pbb.32
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:32:08 -0800 (PST)
Received: from mail02-md.ns.itscom.net (mail02-md.ns.itscom.net. [175.177.155.112])
        by mx.google.com with ESMTP id n8si3060749pax.15.2014.01.08.23.32.06
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:32:07 -0800 (PST)
From: "J. R. Okajima" <hooanon05g@gmail.com>
Subject: Re: [LSF/MM ATTEND] Stackable Union Filesystem Implementation
In-Reply-To: <CAK25hWOUhV2Ygs-Q3cVN-mio+BHB60zJ7J_wZZKb=hOR9mb0ug@mail.gmail.com>
References: <CAK25hWOu-Q0H8_RCejDduuLCA1-135BEp_Cn_njurBA4r7zp5g@mail.gmail.com> <20140107122301.GC16640@quack.suse.cz> <CAK25hWMdfSmZLZQugJ3YU=b6nb7ZQzQFw514e=HV91s0Z-W0nQ@mail.gmail.com> <6469.1389157809@jrobl> <CAK25hWOUhV2Ygs-Q3cVN-mio+BHB60zJ7J_wZZKb=hOR9mb0ug@mail.gmail.com>
Date: Thu, 09 Jan 2014 16:32:05 +0900
Message-ID: <523.1389252725@jrobl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Saket Sinha <saket.sinha89@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org


Saket Sinha:
> > For such purpose, a "block device level union" (instead of filesystem
> > level union) may be an option for you, such as "dm snapshot".
> >
> I imagine that this would make things more complicated as ideally this
> should be done in a filesystem driver. Again a "block device level
> union" would all the more have lesser chances of getting this
> filesystem driver included in the mainline kernel as kernel
> maintainers prefer the drivers to be as simple as possible.

??
I am afraid that I cannot fully understand what you wrote.
If you think "dm snapshot" does not exist currently, and you or someone
else are going to develop a new feature, that is wrong. You already have
"dm snapshot" feature and you can "stack" the block devices by using it.
(cf. http://aufs.sourceforge.net/aufs2/report/sq/sq.pdf which is a bit
old)


J. R. Okajima

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
