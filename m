Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63824C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:58:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 26994217FA
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:58:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 26994217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB37E6B0008; Thu, 18 Apr 2019 07:58:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3ACA6B000A; Thu, 18 Apr 2019 07:58:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A033F6B000C; Thu, 18 Apr 2019 07:58:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 52B4A6B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:58:56 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id u6so1779886wml.3
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:58:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=Ej2RZTxYVhfWNElhAE+zBSI8i6gdUpAzuZwmuzy4s/0=;
        b=THQY9WCVAzqB0gx3bBEqtcLfHICClKWahWCDBIlCWNE1vGS0/sej5QG6XSefh+P4+P
         oadqa9e1dp24K/goJdX3gzQaVDbLlHTYnZuIDTd2gk4LrnkA3HUnLMbh6+MRWQgjp+NW
         OO4Aa0j2NGyGiexXFInrGLJjILm6E5+TEIABZfmlPEeyMnuWILCqNvePJVfkKy8QwIUB
         PusSsuZjLdxa42zji7QR1ge/lOJPoFMmK08ehftS4ADQHBhvFxdadQRa8NIV8uFtCkAJ
         nn4GXGH3hFS2hetGON+WJbmxdK5YFg+zv5llvY2i2e5QKQ3VSF/oWGe91g2ISB2a3xT0
         kcoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWueJOOlRH5s4JhUD/PFqPLg/EPo7L8yi4hWT/S/eSd+OQIgg79
	ZPvJ4pXzhINERx9My7q0eoitHcoRnaABkwywvxY/YPd67palkkzUOybEbUyvYlA0+/9661cUpjC
	iOC9n5MerHOQKrRlkBd2RN1PhWG/h45T707UhmZdIxOD2bU8mSm3arealMMbC9uXw6Q==
X-Received: by 2002:a05:600c:249:: with SMTP id 9mr2789203wmj.149.1555588735934;
        Thu, 18 Apr 2019 04:58:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysdp7JuPxQUzFkjY1YFT+y2IPSw26Yvr303+h3JFFHeJjOvRpGKxKaqpWzsXc4zQXP8Hla
X-Received: by 2002:a05:600c:249:: with SMTP id 9mr2789163wmj.149.1555588735249;
        Thu, 18 Apr 2019 04:58:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555588735; cv=none;
        d=google.com; s=arc-20160816;
        b=N/bha8dr8nddSFx9X8aKTzvbbZtvDagIYS0o9+XIi+/SQsW7DLLS/Ow9PI3Twi6rl7
         mnp5sPrenHnKz6ndKkuTGB6au+XdUqiRYw+EDNrvXj6fWqF0+KwE5aGjoV3MGkQjzYru
         j0OK3KAilg1RxnihFvBrarqJAUw4VQUr4GeGdLc+aDfITfrEX1y/mY7KzeJ0NSlnSx6i
         desE1v0sBGDWzZus9UHsBkZ+CIeim7I109QFA3zBPXf/ju+4nvi2en68xo6SDvjt/eew
         UEBMYAne3A5pXhLWm3Esl+c9Po8KgHQQ71l3ccwF9qHy+52jOswdJQeyR9vKN+5wn993
         r4EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=Ej2RZTxYVhfWNElhAE+zBSI8i6gdUpAzuZwmuzy4s/0=;
        b=qu1DqPjBjyzYAKITb1JB2Z3ZgWfesd8M1i6IKFSm3NfRKpVCHT8vhx2f7QHt9M4Q0Q
         x5cJxb44A/pKoCzGLZN+ShczdzV65hI5jMGS+dGPjkXO021+DzVJ8GLN0KuVOuZR3U01
         k/YHJPeuM0wbC5vSL0qGSCjydLnkyJkrp36ekhGFIy0JoD7jrn2xEhcF3yl/Dd+YdVho
         ukDaxlTiyw02CnojCGe0zqInRDR1p+BUlCFtb1fuThUcpDX8XCIFgJJjNcznf5NtT2Mf
         IGMOPX9Moj1+564r6FQvV6ARBWKpfOWITSlNwgHFxoSh06y5uyjzJpMAZr10mDLsV2Gb
         QIWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v15si1340068wmc.177.2019.04.18.04.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 04:58:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH5gl-0006Cd-9X; Thu, 18 Apr 2019 13:58:47 +0200
Date: Thu, 18 Apr 2019 13:58:45 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Mike Rapoport <rppt@linux.ibm.com>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, 
    Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, 
    David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org, 
    Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, 
    Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
    linux-btrfs@vger.kernel.org, dm-devel@redhat.com, 
    Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
    intel-gfx@lists.freedesktop.org, 
    Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
    Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
    dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, 
    Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>, 
    Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 03/29] lib/stackdepot: Provide functions which operate
 on plain storage arrays
In-Reply-To: <20190418115152.GA13304@rapoport-lnx>
Message-ID: <alpine.DEB.2.21.1904181358030.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084253.337266121@linutronix.de> <20190418115152.GA13304@rapoport-lnx>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019, Mike Rapoport wrote:
> On Thu, Apr 18, 2019 at 10:41:22AM +0200, Thomas Gleixner wrote:
> > 
> > -void depot_fetch_stack(depot_stack_handle_t handle, struct stack_trace *trace)
> > +/**
> > + * stack_depot_fetch - Fetch stack entries from a depot
> > + *
> 
> Nit: kernel-doc will complain about missing description of @handle.

Duh.

> > + * @entries:		Pointer to store the entries address
> > + */
> 
> Can you please s/Returns/Return:/ so that kernel-doc will recognize this as
> return section.

Sure thing.

Thanks,

	tglx

