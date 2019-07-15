Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FEC3C76195
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 14:28:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0537F2064B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 14:28:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="d3/14IV3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0537F2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E7F26B0006; Mon, 15 Jul 2019 10:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 598E36B0007; Mon, 15 Jul 2019 10:28:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4AEB06B0008; Mon, 15 Jul 2019 10:28:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id D943B6B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 10:28:06 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id i18so3903953ljc.4
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 07:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5jX8RO2G+Dqveq3/9ZIxcRNHFe4mw3shiUGtuynCPU0=;
        b=rry8seuli70xdMK9ZmKKwOaltEePutmvNWO8sAYdYCmRzy7OksCpNQ0kZcYDkCi+bD
         qb58pEvWZOvdPGF5r+qbdclf7VaXqOC40Hl2a1v53MgpdUs1mTaftM7GZuG8fQSdDco8
         4JEOuQOuJmPBRBNr2kYU65uTP4GzYPelMHWr4fDNCZ5zA/J4gLfINm/oY8se6zvG9kTh
         +VhbWk+eBlJyVkmgsA9OebA0i4PEWAUZBbKR/aDuzorKQjLg+ZOJhasVSB5fHIdXHOpO
         nbrYtfUEJCWzjAUcXkwfwK15KdFvBFnQwdsmyk0X0+2t2jEZ0ENf9dW6dg8mG9Xu/WHJ
         AJ1g==
X-Gm-Message-State: APjAAAUqAfX7Ts5HAztQpMb8CEV/q+tm1qlx4raGK1C+8C7OZa18rIlm
	tXiXhAsiFIUaTY1hJ2GebRQHWYaGXElLrGrlI4hnru7CA1vzTzimXTg3kAA80gDWQELsWJlzsb0
	77c17eqEEacionPycK6DEO6wh78oPW0jlHr5yJTJFF+CTge3fm6oRez1Z/0sjqQj56A==
X-Received: by 2002:ac2:43cf:: with SMTP id u15mr497044lfl.188.1563200885956;
        Mon, 15 Jul 2019 07:28:05 -0700 (PDT)
X-Received: by 2002:ac2:43cf:: with SMTP id u15mr496995lfl.188.1563200884731;
        Mon, 15 Jul 2019 07:28:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563200884; cv=none;
        d=google.com; s=arc-20160816;
        b=Qdntt3dKnJdqZfQaeRXQGHetDLpJQmM4bXFWdlYEfnD2Jrl5QCIbtqriDX//Q5DwSO
         3B1Y9V2hJI1q7ygm3wCEiHj7Yhs2QWg0MAAnvrwnPfQEHqQhsotcg28vJPn/bt6hfWI2
         4u7JJg4khMWHFqpLPwz8YrK35mH0RA61q2sZe12WVE6yuJH0w9tL8/TWgjl2Uqagis7H
         nJNFcNSY8zGYyV76Cw5wxfRl1zfL29lUhL7aC008u0jeaEk/EB+VLcxxZta7+N30Nd9v
         V/GKdB12cNd/e2aXGdrC/wsZjR3A6lI9CGB8oyT5nj3DAyTXSl3YDOJ2WlyFwA+3EA/a
         VJ1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=5jX8RO2G+Dqveq3/9ZIxcRNHFe4mw3shiUGtuynCPU0=;
        b=krYvrnMBl/tSTGyBZCV/4S/N/Z3UmITVdCMs0Mh23vX3WbgtrLvr5Gc2bGpMVffXP0
         D7ORf+cfQmlWlMdk9Nx51EG/70eGNE3pRV6q85tEDFUvhxtnmckmdgjG4H9FZf4FYYtQ
         aUPYub3mObtRXDbu+x4CszNMUNw3fwXEAbnbzE8Mp3xSFuXNIqkI2C4kWldXUM5v+a0G
         4uwzGNL7VVx0OUlIKTR+m3OtF5aacVZPhK2W9Xc+GcC36V7A0O2LK4e6rTpASu/5mu5q
         B9TRZgD6hz+YvxsObeCTNvdKgbMXoq/Hyiu7Z1ByTK8Sn0Ka4lA8NfLw40LmAzBuexke
         zfhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="d3/14IV3";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 6sor9266097ljs.44.2019.07.15.07.28.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jul 2019 07:28:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="d3/14IV3";
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=5jX8RO2G+Dqveq3/9ZIxcRNHFe4mw3shiUGtuynCPU0=;
        b=d3/14IV3hSNMRDcLy989ICz3liv+mqjjSlW0El1mnKf1DOz5JPMkYTV5X2XfM5proK
         7k1eaAzv9eAe8s9ElN5YSGhnIIHix6PHO4WbLxrSC1Bg4CShvJ3rN8GrZwK9Jrwdixy7
         ziRX3kHL4P0X4Pmx2CRPhDuGSUllqNrR1M2ZTm4YgAoiYdRnRa1OC4xD0LMuspJXA3Ve
         /COxemWlBI3Tl3LClQBSKECiteCiSHEDi4eENFT4WOBuaJ+vsdwS8pMcHCDEH1zrFFZc
         mHIW/MTCDKpoRtJlx8Tw5ldTVnsDbi9sOGSzb2tLaXUDKnurnKlvpB6+BVs3v3a3XZpg
         0lkA==
X-Google-Smtp-Source: APXvYqwkk4wG7LqF3s03ECykm/guY9mj3pBSapqVetXgxHIrnb4xm9bU3dssIzaUILeRZSgr6ITLCg==
X-Received: by 2002:a2e:968f:: with SMTP id q15mr9362552lji.30.1563200884282;
        Mon, 15 Jul 2019 07:28:04 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id h4sm3209138ljj.31.2019.07.15.07.28.02
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Jul 2019 07:28:03 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Mon, 15 Jul 2019 16:27:54 +0200
To: Pengfei Li <lpf.vector@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Uladzislau Rezki <urezki@gmail.com>, rpenyaev@suse.de,
	peterz@infradead.org, guro@fb.com, rick.p.edgecombe@intel.com,
	rppt@linux.ibm.com, aryabinin@virtuozzo.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v4 2/2] mm/vmalloc.c: Modify struct vmap_area to reduce
 its size
Message-ID: <20190715142754.pw55g4b2l6lzoznn@pc636>
References: <20190712120213.2825-1-lpf.vector@gmail.com>
 <20190712120213.2825-3-lpf.vector@gmail.com>
 <20190712134955.GV32320@bombadil.infradead.org>
 <CAD7_sbEoGRUOJdcHnfUTzP7GfUhCdhfo8uBpUFZ9HGwS36VkSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD7_sbEoGRUOJdcHnfUTzP7GfUhCdhfo8uBpUFZ9HGwS36VkSg@mail.gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 12, 2019 at 11:09:00PM +0800, Pengfei Li wrote:
> On Fri, Jul 12, 2019 at 9:49 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Fri, Jul 12, 2019 at 08:02:13PM +0800, Pengfei Li wrote:
> >
> > I don't think you need struct union struct union.  Because llist_node
> > is just a pointer, you can get the same savings with just:
> >
> >         union {
> >                 struct llist_node purge_list;
> >                 struct vm_struct *vm;
> >                 unsigned long subtree_max_size;
> >         };
> >
> 
> Thanks for your comments.
> 
> As you said, I did this in v3.
> https://patchwork.kernel.org/patch/11031507/
> 
> The reason why I use struct union struct in v4 is that I want to
> express "in the tree" and "in the purge list" are two completely
> isolated cases.
> 
I think that is odd. Your v3 was fine to me. All that mess with
struct union struct makes it weird, so having just comments there
is enough, imho.

<snip>
-               __free_vmap_area(va);
+               merge_or_add_vmap_area(va,
+                       &free_vmap_area_root, &free_vmap_area_list);
+
<snip>
Should not be done in this patch. I can re-spin "mm/vmalloc: do not keep unpurged areas in the busy tree"
and add it there. So, as a result we will not modify unlink_va() function.

Thus, this patch will reduce the size only, and will not touch other parts.

--
Vlad Rezki

