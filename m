Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B67CEC4740C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 00:59:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A5F62082C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 00:59:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NJvhTiFV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A5F62082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 144896B0003; Mon,  9 Sep 2019 20:59:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F4DE6B0006; Mon,  9 Sep 2019 20:59:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 00AE56B0007; Mon,  9 Sep 2019 20:59:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id D54576B0003
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 20:59:32 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 8DB5A8243760
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 00:59:32 +0000 (UTC)
X-FDA: 75917202984.23.wood24_190e89c34b745
X-HE-Tag: wood24_190e89c34b745
X-Filterd-Recvd-Size: 5072
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 00:59:32 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id 21so15541276otj.11
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 17:59:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CsXKhS0XQfiMyJ7mpn68yj+pi0x2EB9djLY2PKEnIvE=;
        b=NJvhTiFVojZBMKp/UMfPBAcdGNpXPqcLf0l+uBgrLnIMN5Lb/QdwFjIZfVicukwWFB
         0BE0Y+Sg6WKACTgNtrnrQa/X3VChC2oACDmCmxD459s/W+xYAeus4fF5TZyW2b0UMzo3
         AokqCH7lHtfOqpzhG6lNtzaLHCY+vqKQTvaoID9hJcP42QZU0b49qjMFU27/HD1prwuN
         cF9l/F7lbMEB3j4/Sp9MMP2j0UrdTfhf/mVzkC5EKEfd48ApkUwlyu7MEfr14ZNnUh1f
         9GCjnUzgAi4/Zb6Bp8NLgbDeBtmQF/6zTxqr/uZo7U8A+ABkluT8xBMZRSwUuYwMeKSF
         BuSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=CsXKhS0XQfiMyJ7mpn68yj+pi0x2EB9djLY2PKEnIvE=;
        b=Y74Hpvb/ENuHyQFlwXqThp6K931fBGgm6rPKMV61mYMlQpKTfaGiioJi32d7KyJ45g
         sOr7C+Esu8PFK0wlbn8Mb8u7qxXQ8hBZbVsCAXTEJN7p8FKXTngDpRWdldS3MhIVC1S0
         rzliPDU6mF1nP/U8DZizc+kh8x+2fr8gm2AjBwZN+1mHIwPV1x5sL45Fp5+IVSQjP0ho
         Uf8bADFe1FzS4jSnoIo5PVgxog23pmh0TLSQbsJ+Lf6VMgJE4x3KNd0ZuzHG5sC3XlO4
         82E4jbU21+lTaxkrWihKC8vzQpAuFVZ9veEsHVXu1o01p5gqIpZ5P2rzol/J8nLDc/2U
         B8lQ==
X-Gm-Message-State: APjAAAXVXW25EuEUJKGWRDOlDWuh1xqpbEclyZGPn0O6qnHO51hzn155
	xGJXu1TzlelxryxA452gfmTajH0o+SbhPDzFYmY=
X-Google-Smtp-Source: APXvYqzetzA+5LWgRCKMkAjNsWaMh6dQ5gbCFWCKiX+78NvMpP5hbC/YDfDw36hEGtXaINoGd7V4K3G55Mw6saIcHwk=
X-Received: by 2002:a9d:1ec:: with SMTP id e99mr17314668ote.173.1568077171489;
 Mon, 09 Sep 2019 17:59:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190909170715.32545-1-lpf.vector@gmail.com> <20190909170715.32545-4-lpf.vector@gmail.com>
 <20190909195955.GA2181@tower.dhcp.thefacebook.com>
In-Reply-To: <20190909195955.GA2181@tower.dhcp.thefacebook.com>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Tue, 10 Sep 2019 08:59:20 +0800
Message-ID: <CAD7_sbHgfNB-rYQ=uOGL14Pmf8VgChbnwh804r8LT_o73iH4Hg@mail.gmail.com>
Subject: Re: [PATCH v2 3/4] mm, slab_common: Make 'type' is enum kmalloc_cache_type
To: Roman Gushchin <guro@fb.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, 
	"cl@linux.com" <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, 
	"rientjes@google.com" <rientjes@google.com>, "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 10, 2019 at 4:00 AM Roman Gushchin <guro@fb.com> wrote:
>
> On Tue, Sep 10, 2019 at 01:07:14AM +0800, Pengfei Li wrote:
>
> Hi Pengfei!
>
> > The 'type' of the function new_kmalloc_cache should be
> > enum kmalloc_cache_type instead of int, so correct it.
>
> I think you mean type of the 'i' variable, not the type of
> new_kmalloc_cache() function. Also the name of the patch is
> misleading. How about
> mm, slab_common: use enum kmalloc_cache_type to iterate over kmalloc caches ?
> Or something like this.
>

Ok, this name is really better :)

> The rest of the series looks good to me.
>
> Please, feel free to use
> Acked-by: Roman Gushchin <guro@fb.com>
> for patches [1-3] in the series after fixing this commit message and
> restoring __initconst.
>

Thanks!

> Patch [4] needs some additional clarifications, IMO.
>

I will add more clarification in v3.

> Thank you!
>
> >
> > Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
>
>
>
> > ---
> >  mm/slab_common.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/mm/slab_common.c b/mm/slab_common.c
> > index cae27210e4c3..d64a64660f86 100644
> > --- a/mm/slab_common.c
> > +++ b/mm/slab_common.c
> > @@ -1192,7 +1192,7 @@ void __init setup_kmalloc_cache_index_table(void)
> >  }
> >
> >  static void __init
> > -new_kmalloc_cache(int idx, int type, slab_flags_t flags)
> > +new_kmalloc_cache(int idx, enum kmalloc_cache_type type, slab_flags_t flags)
> >  {
> >       if (type == KMALLOC_RECLAIM)
> >               flags |= SLAB_RECLAIM_ACCOUNT;
> > @@ -1210,7 +1210,8 @@ new_kmalloc_cache(int idx, int type, slab_flags_t flags)
> >   */
> >  void __init create_kmalloc_caches(slab_flags_t flags)
> >  {
> > -     int i, type;
> > +     int i;
> > +     enum kmalloc_cache_type type;
> >
> >       for (type = KMALLOC_NORMAL; type <= KMALLOC_RECLAIM; type++) {
> >               for (i = KMALLOC_SHIFT_LOW; i <= KMALLOC_SHIFT_HIGH; i++) {
> > --
> > 2.21.0
> >
> >

