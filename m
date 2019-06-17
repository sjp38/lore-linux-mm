Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6814C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A513820833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:45:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A513820833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3975E8E0002; Mon, 17 Jun 2019 10:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 347A48E0001; Mon, 17 Jun 2019 10:45:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 237778E0002; Mon, 17 Jun 2019 10:45:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 040D48E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:45:07 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so9406935qtm.17
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:45:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=1ZuDMi3lli8OO05kFY206yEp9wlXM0BbyA8+D2np9Sw=;
        b=LK4AaUn4X9xpg86qdMAzsL5T2YcWT6eXkqkkrFTQhCqy2thUOOV5HOxKJeT3lTfUs/
         6kzBkXpdEI0DuMYV+CHklO0MGPBa9Sj3x2X6iap0mAwrrL1PI4mInmJyHDJ3pgz4PKyx
         gv/ys7t2bzvlljyErwySY8x0R+5Igr7EMJycM5lRzfa1+b77QJ9s4cFxjxhIu89eSLAT
         qj5ogW7Kqdq0y81hyYiLHsee2zP2B3h4uXSlBWloryvTyfwlr11VW+TI1mhrbcG/mQmd
         ngalB1CnXSunfyK/TsJcaXo2NWL40pbNijI/Oxhy26R7GWAnNF1h4fE6+mPFx3WrLSVK
         A5yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAX3gr0jkMlZ+nPlLg8pEBFjHNlXz8hKX9EzkpMM776HA29d5Y42
	zD+7zgzTjgFVtiqPfn52pFJgQVFYgXATeZrtfgfl9quA3b05MthnxMI0FtFbD+4gNoe8/cKgOFl
	pv9XYP3Oc5W45gSITyuqa3+tZyjuaizbyfkYVsnVKDYH+cNY3gpKm/tcqMCkaLeQ=
X-Received: by 2002:a0c:eecd:: with SMTP id h13mr21679274qvs.46.1560782706807;
        Mon, 17 Jun 2019 07:45:06 -0700 (PDT)
X-Received: by 2002:a0c:eecd:: with SMTP id h13mr21679243qvs.46.1560782706392;
        Mon, 17 Jun 2019 07:45:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560782706; cv=none;
        d=google.com; s=arc-20160816;
        b=J4i/1GgbITYgNpqN+u22aZP2XUq/H3CL6D0W2/GxARSGAieVD8Aw/v+UjGWDqKiTGe
         /XMZ1/uqvH5istG9lapCGGGu5LNNiISJhy63O1qjnOCkVIvo5UK5zwDFc+yLIBKiUbvl
         JN1aSCZ2VCiUuDggtdbNMQTWAqI06k/2X7b9oODxDkrpBYTu+QDOI+Vg0OiU6fI1PIx9
         bMjNlbZk/J/5aE6sXZyCo6siwsVTvA8BwkEKBVkz/oIpTEVCkBL3PAwXMdLF/VnXBqg8
         ML6s6vgzKzs+52GydcGCBe4Q2jTltV/XVSwBbPST3fZNEXZmAawqVIExnB8mecwj/dUb
         pRqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=1ZuDMi3lli8OO05kFY206yEp9wlXM0BbyA8+D2np9Sw=;
        b=Jf9KRl9Ji+5UEOwg0rx865cQZHTMtjg+EgV8jyLJAkDm5hODI6Yo+0KQBUTeMw4tYz
         ejBsZHxuM9mYgBoeWHiApsm6TV8TIByGRYigSwkf+kBdOO4cZNUvDxnxqzF/bnStcH5i
         bfGtoZWoHwNBp/2BgsWVJ+NFLZjX1f1/ABn+hpy3Gecy+MAXw1n1TkRAuE8MfEaRFAwA
         0qvQUIJbRzR2Lf4aGZ0/zag28mmPu5jjsQNtCzGp3cPdkU9moG8FmJlvPOGLIJiUoKX+
         w91r6L3XjG4g2w1xPPU9MjlIX2v7DP8zuFvQI5kwGI9RA9JRUVdbiN84NyfmbPe6Vau/
         0Xjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m50sor16450081qtf.44.2019.06.17.07.45.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 07:45:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqy9Ua2AlWMGNVTT5MH9RdtUYwxp9mnEiPm+6tBRLWINKiftc1eLzmlvbDFk91T4uD74kg4HJbkksF88ISPUJ+s=
X-Received: by 2002:ac8:3485:: with SMTP id w5mr17348190qtb.142.1560782706039;
 Mon, 17 Jun 2019 07:45:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190617121427.77565-1-arnd@arndb.de> <20190617141244.5x22nrylw7hodafp@pc636>
In-Reply-To: <20190617141244.5x22nrylw7hodafp@pc636>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 17 Jun 2019 16:44:49 +0200
Message-ID: <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
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

On Mon, Jun 17, 2019 at 4:12 PM Uladzislau Rezki <urezki@gmail.com> wrote:
>
> On Mon, Jun 17, 2019 at 02:14:11PM +0200, Arnd Bergmann wrote:
> > gcc points out some obviously broken code in linux-next
> >
> > mm/vmalloc.c: In function 'pcpu_get_vm_areas':
> > mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> >     insert_vmap_area_augment(lva, &va->rb_node,
> >     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> >      &free_vmap_area_root, &free_vmap_area_list);
> >      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> > mm/vmalloc.c:916:20: note: 'lva' was declared here
> >   struct vmap_area *lva;
> >                     ^~~
> >
> > Remove the obviously broken code. This is almost certainly
> > not the correct solution, but it's what I have applied locally
> > to get a clean build again.
> >
> > Please fix this properly.
> >

> >
> Please do not apply this. It will just break everything.

As I wrote in my description, this was purely meant as a bug
report, not a patch to be applied.

> As Roman pointed we can just set lva = NULL; in the beginning to make GCC happy.
> For some reason GCC decides that it can be used uninitialized, but that
> is not true.

I got confused by the similarly named FL_FIT_TYPE/NE_FIT_TYPE
constants and misread this as only getting run in the case where it is
not initialized, but you are right that it always is initialized here.

I see now that the actual cause of the warning is the 'while' loop in
augment_tree_propagate_from(). gcc is unable to keep track of
the state of the 'lva' variable beyond that and prints a bogus warning.

        Arnd

