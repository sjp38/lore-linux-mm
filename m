Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4DD93C31E50
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 148B52084B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:04:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 148B52084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6D248E0004; Mon, 17 Jun 2019 10:04:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1E5A8E0001; Mon, 17 Jun 2019 10:04:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90B9A8E0004; Mon, 17 Jun 2019 10:04:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD1E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:04:33 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so9338910qte.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:04:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=Wyv3XjYWUgnOQsz9LKXunlG3ze5V59yjJvNLNW3SDc4=;
        b=N26+1+F+hW8vZvNs1NuZXIdSOAsDRWnuncoW+aClnlfk/lERZKmfyPlF5gnb5xOCGV
         B443kaDY7mhvgV5gkvmW21eFqbBnK+5okUdkjsRHhnTaFdp2M7DpvWqTWiihSjksZJ60
         J35l4CsO7UXj9e5t0Qfo/bLn28uHAN9bntPlDE8GN0RYtnxLc9Oyxew56I3mJEEBtNWj
         lzSps3ZdnrJ9Fi5peBZj2pEXE3KF+sZdWLhBTFjrwQdngk/bk+7PNgBW+lEnDBfRdRWd
         Ts6WnOD7FgYL06BxApW0fZyVzvCcS+KuE6l0vzIEvWXpE60U0JJDfuHdr34CRmAbJKPh
         kHHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAXP/GvOoCuK0Fkxt6CK1ImiqW1LpF83W9G4yi8ulTUnJFdmxrw3
	LFPvO8mP5iGHxxFZi4P91sA6gv7oGzP+ggaCGmWZ+wDt6iRencOvDx3F4m+NTg9eB2uBccV5p0A
	46pPjjp1O6pjF0mrrP6JyEQLjvXOd4TCLigcctppnwFoKBYGtoJACS9fTw2m404s=
X-Received: by 2002:aed:3b25:: with SMTP id p34mr93948394qte.289.1560780273201;
        Mon, 17 Jun 2019 07:04:33 -0700 (PDT)
X-Received: by 2002:aed:3b25:: with SMTP id p34mr93948346qte.289.1560780272642;
        Mon, 17 Jun 2019 07:04:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560780272; cv=none;
        d=google.com; s=arc-20160816;
        b=GGNzNrUO4lY9RKcr94GMsiPulQYMtyMSsd8EWlWrXDB49Y7cLGPxdwBPtJWOpjd5a3
         V/JGzV3NQbG5aI31I/L+O/bRv3MIz/xOcqaMnXovu7k1v9Pjk2AXB/o7LeNVrH8/ETC7
         +oYvYC8JkqU3viuD8AQqeVR0Wq8bQxTna3yK/mdFtwF99FioO6RDFZtgdgFxJ+3IKTRA
         /TLhwirLrD4OiOWrQGUbx/a1T+UVAXBXbGSrD26vLWX3RS9kdRfHed+anR7YIZIbLa9R
         mYvarneIiyhvuIC895E7Ef9Mfo0+hXTERtu77KbpZ/FS6xwZH9OEB9X9k66w7m/RivRA
         /yAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=Wyv3XjYWUgnOQsz9LKXunlG3ze5V59yjJvNLNW3SDc4=;
        b=c0I+UqR2udUBjU6M1uoP8laG5kS9ydSnlCCKkSte14kySQJFmQB+ibGi+a3tGDODyv
         WIHHfwwvYPyd/COJx5MDF/8i69PSSN1XV0KBlJcnlRnQcTDV2gj9bMlYhwViFK4PZXxh
         dc3P4RXEXkQJmaWXXAiaR3bo3abWKacDWCavPxthtEfxHJzxQt5tK2e8zBwvfKFCxG7u
         nbMLhMaWuqE54TiPHdtwEnkAfb4vBQvWIeW8icXJdC5xlOVP/MlAoFiq79OYY/ToXGvf
         AghUPkJqGDmVi3WlRk4Esu8K10E8yfWZ2LgyvLP6NUz/cAfUsGlFILL/pTKMDtQ53cfk
         sFSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n4sor7215920qke.58.2019.06.17.07.04.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 07:04:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqxfILWhAdKXQ4OWbwL16dTg8+0rppOl294W+m7hdTdNP3jcvSOtAIQCjQ3rZPM0axb4x4PZsoZRGkPIyUFm8U8=
X-Received: by 2002:ae9:e608:: with SMTP id z8mr80292298qkf.182.1560780272294;
 Mon, 17 Jun 2019 07:04:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190617121427.77565-1-arnd@arndb.de> <457d8e5e453a18faf358bc1360a19003@suse.de>
In-Reply-To: <457d8e5e453a18faf358bc1360a19003@suse.de>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 17 Jun 2019 16:04:14 +0200
Message-ID: <CAK8P3a0+jOW==OOx_CLj=TCsG5EBK2ni6kw1+PexJLAC2NEp_g@mail.gmail.com>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in pcpu_get_vm_areas
To: Roman Penyaev <rpenyaev@suse.de>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, 
	Matthew Wilcox <willy@infradead.org>, Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, 
	Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, 
	Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Mike Rapoport <rppt@linux.ibm.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 3:49 PM Roman Penyaev <rpenyaev@suse.de> wrote:
> >               augment_tree_propagate_from(va);
> >
> > -             if (type == NE_FIT_TYPE)
> > -                     insert_vmap_area_augment(lva, &va->rb_node,
> > -                             &free_vmap_area_root, &free_vmap_area_list);
> > -     }
> > -
> >       return 0;
> >  }
>
>
> Hi Arnd,
>
> Seems the proper fix is just setting lva to NULL.  The only place
> where lva is allocated and then used is when type == NE_FIT_TYPE,
> so according to my shallow understanding of the code everything
> should be fine.

I don't see how NULL could work here. insert_vmap_area_augment()
passes the va pointer into find_va_links() and link_va(), both of
which dereference the pointer, see

static void
insert_vmap_area_augment(struct vmap_area *va,
        struct rb_node *from, struct rb_root *root,
        struct list_head *head)
{
        struct rb_node **link;
        struct rb_node *parent;

        if (from)
                link = find_va_links(va, NULL, from, &parent);
        else
                link = find_va_links(va, root, NULL, &parent);

        link_va(va, root, parent, link, head);
        augment_tree_propagate_from(va);
}

static __always_inline struct rb_node **
find_va_links(struct vmap_area *va,
        struct rb_root *root, struct rb_node *from,
        struct rb_node **parent)
{
       ...
                       if (va->va_start < tmp_va->va_end &&
                                va->va_end <= tmp_va->va_start)
       ...
}

static __always_inline void
link_va(struct vmap_area *va, struct rb_root *root,
        struct rb_node *parent, struct rb_node **link, struct list_head *head)
{
        ...
        rb_link_node(&va->rb_node, parent, link);
        ...
}

       Arnd

