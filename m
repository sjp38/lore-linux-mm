Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1AEFC04E87
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:36:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C85720848
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 16:36:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="LKtwsZc+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C85720848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1B676B0005; Fri, 17 May 2019 12:36:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCC786B0006; Fri, 17 May 2019 12:36:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBB296B0008; Fri, 17 May 2019 12:36:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93CFC6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 12:36:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id p124so4712358pga.6
        for <linux-mm@kvack.org>; Fri, 17 May 2019 09:36:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=IxZh0SFkgKtgTvTNPdcwfcLCN5N/2CbppecqxizinxM=;
        b=JSDkeg456su8Zu1awz25Nb1q532MARwIbEU4VhmNAv4IyDOGJLVVvPjx7bmd1kcCr9
         9hr0CXUuV70gcLgh1eaqCekpCLeJjRcSISghdYoysmWDBgd93gMSll7t2uPAug0oOnPM
         I7BUPzl5cJfgrUH3MQ3LkmmlKu74mZCHIvWAD+x7tHI3mBF12iGPitrXZlXxMHTDLaot
         ECLwEWY3HXy7mA2ZQEMvdfv/4Yh5zLzv1ooMswZeIRy8AWVnEL3q8YrZWaQto0VQBNxc
         Kz/sG+Nbp+NyBn3mbLmdVi/pCMEvaWzW6WUggiwaKtaiEJmbRnms+MdI3Oisd0JrALQX
         UoAQ==
X-Gm-Message-State: APjAAAUcJWd6T+w992SGLyOjTd346XuOXmLoVnxf+/X7tYBBQlrx5sD9
	49CPnwsdDuAe7jS5qm7vuLiED12FL7BSKmAeFr1mFsKFYO6rtgSIdgtAG69KaTiQujX/bySmHzg
	yNVRO6xrdxsX7qle9lxo2ZT0DbSsx4/mqTqiSGwd3mW0D/JLVLenib8cPDa8vGRS/Ow==
X-Received: by 2002:aa7:9dc9:: with SMTP id g9mr25346822pfq.228.1558110999176;
        Fri, 17 May 2019 09:36:39 -0700 (PDT)
X-Received: by 2002:aa7:9dc9:: with SMTP id g9mr25346766pfq.228.1558110998467;
        Fri, 17 May 2019 09:36:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558110998; cv=none;
        d=google.com; s=arc-20160816;
        b=sS9SxQdlVYLO6iI81BPuZUpZS6OhbYeU55VYMzkc76D+O0nfKtfhKugSYkqpUxtqA6
         2P6m1V0vOeqCSp56EGZYgPokbqeNrszu5OW08ImnYRBrBJGFBYv74N7sum/918m5J/xZ
         9Lue1cTaVOJtNDVO/+GreIlHYTrBx/pX5MMY2bn+y0kz0EtY8we/G709HqsTxa17hc9Z
         dR04svaMnlDllzoyfHdX17/fw71Nx8kcpMqYaEZrohQqRQ+2G5Sm0ojaLRO2l7pU+HsS
         vqUA26jlPHvdMJGGVABb0WBZL6O/2B4AyekPKZ7znOfrN14YFXwwf5T0GOQ0IMqqBm0s
         CQYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=IxZh0SFkgKtgTvTNPdcwfcLCN5N/2CbppecqxizinxM=;
        b=FJLpTAtvCMZw3WLGYk6Jj7jzHhQ5diDMplHPYUmzaNtATDHQBzmMhI1fvoeIkWU2Y8
         OMi+iluk3rB7U1ZmVN116ecTrBvvEDSWp5uE78tn5UMSrnt/xY18LRrhr3Tty/sHRrHe
         Q9Sy5ZCOTuNeX8BD81JtIm1N3I99Tm3Bw/h7yXNiwmKu8dPXmowFRR1qq88IO4Iy4Qei
         VKRB0OxHtxPGXfOU66GSDrROOZq8yAG2IZPbP7HN4x9aW08zNJshzl76IAUd8UuIkZgc
         y0r4jVXZm9dD7z1vJvbrdBJZ2zlN7yzim1iHnITJ0inVfRYCFMyTdyN4nJGazeM0TqZ1
         mEVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=LKtwsZc+;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v2sor10242999plo.32.2019.05.17.09.36.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 09:36:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=LKtwsZc+;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=IxZh0SFkgKtgTvTNPdcwfcLCN5N/2CbppecqxizinxM=;
        b=LKtwsZc+FJwBUNCIrb11Y8GMSqCZzahf6uwtE13uOAtzpkKArDH0dIAHVyh3q8Aw/I
         Y4JNbF8h+RK2YX8THwM9WWZfYiZndP/ijiJWhxq83LPfS7ocwy7iMhbMiGe+pULQw//3
         aF2hXKEvTcj8VBtfWGt+/eQWXW1mCx/Jpv9gY=
X-Google-Smtp-Source: APXvYqwar3NELFkZUW3aLvqx4k8Fr6KsRKzOY1J6woNFnEa2TxFFiU3swrxEMldmcv15oXzwZrP4YA==
X-Received: by 2002:a17:902:2bc5:: with SMTP id l63mr59603305plb.202.1558110998204;
        Fri, 17 May 2019 09:36:38 -0700 (PDT)
Received: from www.outflux.net (smtp.outflux.net. [198.145.64.163])
        by smtp.gmail.com with ESMTPSA id t25sm18130915pfq.91.2019.05.17.09.36.37
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 17 May 2019 09:36:37 -0700 (PDT)
Date: Fri, 17 May 2019 09:36:36 -0700
From: Kees Cook <keescook@chromium.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Alexander Potapenko <glider@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>
Subject: Re: [PATCH v2 1/4] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <201905170928.A8F3BEC1B1@keescook>
References: <20190514143537.10435-1-glider@google.com>
 <20190514143537.10435-2-glider@google.com>
 <20190517140446.GA8846@dhcp22.suse.cz>
 <CAG_fn=W4k=mijnUpF98Hu6P8bFMHU81FHs4Swm+xv1k0wOGFFQ@mail.gmail.com>
 <20190517142048.GM6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190517142048.GM6836@dhcp22.suse.cz>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 04:20:48PM +0200, Michal Hocko wrote:
> On Fri 17-05-19 16:11:32, Alexander Potapenko wrote:
> > On Fri, May 17, 2019 at 4:04 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Tue 14-05-19 16:35:34, Alexander Potapenko wrote:
> > > > The new options are needed to prevent possible information leaks and
> > > > make control-flow bugs that depend on uninitialized values more
> > > > deterministic.
> > > >
> > > > init_on_alloc=1 makes the kernel initialize newly allocated pages and heap
> > > > objects with zeroes. Initialization is done at allocation time at the
> > > > places where checks for __GFP_ZERO are performed.
> > > >
> > > > init_on_free=1 makes the kernel initialize freed pages and heap objects
> > > > with zeroes upon their deletion. This helps to ensure sensitive data
> > > > doesn't leak via use-after-free accesses.
> > >
> > > Why do we need both? The later is more robust because even free memory
> > > cannot be sniffed and the overhead might be shifted from the allocation
> > > context (e.g. to RCU) but why cannot we stick to a single model?
> > init_on_free appears to be slower because of cache effects. It's
> > several % in the best case vs. <1% for init_on_alloc.
> 
> This doesn't really explain why we need both.

There are a couple reasons. The first is that once we have hardware with
memory tagging (e.g. arm64's MTE) we'll need both on_alloc and on_free
hooks to do change the tags. With MTE, zeroing comes for "free" with
tagging (though tagging is as slow as zeroing, so it's really the tagging
that is free...), so we'll need to re-use the init_on_free infrastructure.

The second reason is for very paranoid use-cases where in-memory
data lifetime is desired to be minimized. There are various arguments
for/against the realism of the associated threat models, but given that
we'll need the infrastructre for MTE anyway, and there are people who
want wipe-on-free behavior no matter what the performance cost, it seems
reasonable to include it in this series.

All that said, init_on_alloc looks desirable enough that distros will
likely build with it enabled by default (I hope), and the very paranoid
users will switch to (or additionally enable) init_on_free for their
systems.

-- 
Kees Cook

