Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56F28C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:51:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 163442084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:51:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 163442084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B83828E0006; Mon, 17 Jun 2019 10:51:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B33438E0001; Mon, 17 Jun 2019 10:51:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A496C8E0006; Mon, 17 Jun 2019 10:51:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FB338E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:51:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p43so9415717qtk.23
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:51:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=q8FJ2kwlqp+MobuH8TFvTjKHjPn6ix+Pc/KnlT4DZoQ=;
        b=bpLJnwiCu/ddr0km0Hd7Zd5FqWE/u+xLhUwL6/wEp7NCzF62zytEhfSI1hZfYoLGCE
         AfDKlEsjMIJWnKT/tLJyoOB95jJaoDF2/DLEbUOjzeVHai2kdPbhZW5KQdVdzMhm8lcH
         2hajAEoANJGGPxSSiQ+G+Xd7HYzJeqee894hGu/c47as3yfzOgbRM5DMS9JWAkpZI7aM
         KA9vDrnUPI8gTBjBeBAs8tCIwezqzklFMJ3Jb4J655d8ifARIZlNBB4VUeuZK75zxiFK
         jymR/UNN0uf0nPB+3oEqN4URtUQAlqMqfWXSFgsz6eh3zp/QHxplRADC1npSC8RzgMy4
         CXGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAUCyRiizlAMJho6/VF5WG+0T0mqkeEzU4dSnfbhXJwbivqf0GA7
	EL6NDNGL1LUUZpSPODrkGBt9fNhwn5ZSD3jFf7en0+TmIAOI1ZQwnC2itnf4JtUsYBo6K1K2MzQ
	/41harKHqu9dz5pYrO0acp34SC2aBOaFHFnhH5TxIEdbC17S+Ea4onYNOS5ChtPA=
X-Received: by 2002:a37:6253:: with SMTP id w80mr15693587qkb.153.1560783066268;
        Mon, 17 Jun 2019 07:51:06 -0700 (PDT)
X-Received: by 2002:a37:6253:: with SMTP id w80mr15693525qkb.153.1560783065692;
        Mon, 17 Jun 2019 07:51:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560783065; cv=none;
        d=google.com; s=arc-20160816;
        b=RmIqXykEQF+O+RXNaU8V9SnrkasL0BoIHBBXJqVevIoAnB5WPJPtX0Xjy/MmLP01He
         cvTgHdv0AyxNMMCxtInfWYSWbDpsFTPZlc/3eOV5953858NdZd9GIG2+7E/2n6maY0Lx
         H3Usq5c96yJWyZ7W7QfyM3jGT+tXXulLKVMsDyDlHxVHHUj209EqL0OrXfVJecznTXE4
         YxnaFTDCrmegLIEYw1D9wvHAjUMMYJFX0icMg1P+13XS01cbyGbp8MFtrLh93aVKmWR/
         XHZTy5yrMX7iE7CG30lBVPCKpC8Ng8NNYlj9tURuKB2iDy/w6KN/vRG6j2cTO1FnsktS
         YCVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=q8FJ2kwlqp+MobuH8TFvTjKHjPn6ix+Pc/KnlT4DZoQ=;
        b=wZSkc1OAtWYJpEp1l/Fi7phxC98OMgV6fS5sFjMDaXO+AAMD+iHPO5yB0E8cvq07Rj
         jDU3FVKz82PFh5Tv/ICAVafzVzgN7qgCJ3ulOQ0zA+I8WiPVZjmwLy/VCBQNUABTAGMW
         za4MVjwK3CCwBFnqe0VCePtSaNo0udHEC43qgKEgXPj+zumUTL5qu8i135d+QoT0Jevy
         6CXP+pNbOvNMgUhtaKcw10fNkVg1D98CAPHwwP039aNH5MJW9tLdlYzBFQsLemo4vwl9
         tALmNhhMaoa8CjE+3ragiEhWJzpmzpqDEKrNQAam5tP6Q+LV+Bj35vyDh2/udOk7llBS
         Dl0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s2sor7412632qkg.82.2019.06.17.07.51.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 07:51:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqzGHPK0SuAOiFmF36ZCL+V6bBx3pWjrebtOkfLE1KzmEr0hyrwu/CO4hn9QYjNX0GmKoAn1mJ5RYvF4ApuHWDg=
X-Received: by 2002:ae9:e608:: with SMTP id z8mr80517080qkf.182.1560783065346;
 Mon, 17 Jun 2019 07:51:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190617121427.77565-1-arnd@arndb.de> <20190617141244.5x22nrylw7hodafp@pc636>
 <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
In-Reply-To: <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 17 Jun 2019 16:50:48 +0200
Message-ID: <CAK8P3a0pnEnzfMkCi7Nb97-nG4vnAj7fOepfOaW0OtywP8TLpw@mail.gmail.com>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in pcpu_get_vm_areas
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, 
	Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Roman Penyaev <rpenyaev@suse.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Andrey Ryabinin <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 4:44 PM Arnd Bergmann <arnd@arndb.de> wrote:
> On Mon, Jun 17, 2019 at 4:12 PM Uladzislau Rezki <urezki@gmail.com> wrote:
> >
> > On Mon, Jun 17, 2019 at 02:14:11PM +0200, Arnd Bergmann wrote:
> > > gcc points out some obviously broken code in linux-next
> > >
> > > mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> > > mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> > >     insert_vmap_area_augment(lva, &va->rb_node,
> > >     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > >      &free_vmap_area_root, &free_vmap_area_list);
> > >      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > > mm/vmalloc.c:916:20: note: 'lva' was declared here
> > >   struct vmap_area *lva;
> > >                     ^~~
> > >
> > > Remove the obviously broken code. This is almost certainly
> > > not the correct solution, but it's what I have applied locally
> > > to get a clean build again.
> > >
> > > Please fix this properly.
> > >
>
> > >
> > Please do not apply this. It will just break everything.
>
> As I wrote in my description, this was purely meant as a bug
> report, not a patch to be applied.
>
> > As Roman pointed we can just set lva = NULL; in the beginning to make GCC happy.
> > For some reason GCC decides that it can be used uninitialized, but that
> > is not true.
>
> I got confused by the similarly named FL_FIT_TYPE/NE_FIT_TYPE
> constants and misread this as only getting run in the case where it is
> not initialized, but you are right that it always is initialized here.
>
> I see now that the actual cause of the warning is the 'while' loop in
> augment_tree_propagate_from(). gcc is unable to keep track of
> the state of the 'lva' variable beyond that and prints a bogus warning.

I managed to un-confuse gcc-8 by turning the if/else if/else into
a switch statement. If you all think this is an acceptable solution,
I'll submit that after some more testing to ensure it addresses
all configurations:

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a9213fc3802d..5b7e50de008b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -915,7 +915,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
 {
        struct vmap_area *lva;

-       if (type == FL_FIT_TYPE) {
+       switch (type) {
+       case FL_FIT_TYPE:
                /*
                 * No need to split VA, it fully fits.
                 *
@@ -925,7 +926,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
                 */
                unlink_va(va, &free_vmap_area_root);
                kmem_cache_free(vmap_area_cachep, va);
-       } else if (type == LE_FIT_TYPE) {
+               break;
+       case LE_FIT_TYPE:
                /*
                 * Split left edge of fit VA.
                 *
@@ -934,7 +936,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
                 * |-------|-------|
                 */
                va->va_start += size;
-       } else if (type == RE_FIT_TYPE) {
+               break;
+       case RE_FIT_TYPE:
                /*
                 * Split right edge of fit VA.
                 *
@@ -943,7 +946,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
                 * |-------|-------|
                 */
                va->va_end = nva_start_addr;
-       } else if (type == NE_FIT_TYPE) {
+               break;
+       case NE_FIT_TYPE:
                /*
                 * Split no edge of fit VA.
                 *
@@ -980,7 +984,8 @@ adjust_va_to_fit_type(struct vmap_area *va,
                 * Shrink this VA to remaining size.
                 */
                va->va_start = nva_start_addr + size;
-       } else {
+               break;
+       default:
                return -1;
        }

       Arnd

