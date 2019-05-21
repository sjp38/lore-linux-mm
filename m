Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9164C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:00:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64ED521773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 17:00:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0gl6NyxD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64ED521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E62E6B0003; Tue, 21 May 2019 13:00:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 199016B0006; Tue, 21 May 2019 13:00:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 086776B0007; Tue, 21 May 2019 13:00:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C69586B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 13:00:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id y9so11720295plt.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 10:00:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qs9NxSIsFhIUi5q0vuHy+yWUBymowMuQjy0VmUzDrB4=;
        b=Moe0lrPSNzKFPswAyM/5i+w10QEopdENHz2WRvBOZvhL6Liwg8kJQ+z6HmN3uLOV/w
         ut7Khbl+dNGVF5Hrk/KL9p8+0QCLSWbRidyFciIa9PX6rDpHGTSkv3j7YPjbyHO7s6sG
         N4j4AlNNLTgAXQ7IHLqvRo9/nQsthgBmp/zE68UVKojaChGIx2XLvpCnU5A6497c1PdS
         O9cFlVUDjBv1oRvOY0ebrY2EuG+QXpLG6JjeXBw+PXGDasZLa47ppkYw5xDU5ZNaeEsK
         emOKYvVQbsPQLnPhBGvas2QG8n9e+KUZOvK2pAMMTnfg7bNT3QNP4nbosaz82TLCynzb
         7fpw==
X-Gm-Message-State: APjAAAW77Ga0Q7P3OVMAOT0MJr+ltYvnHiNBKtgYyBkBW9RyyCTsvz3z
	PY72aDCTPUVPMCtg9a+FAmWU7AkcEyJN5c/AJcR8PNolMCx7ceg3PPZ+oQZgjK+yKudb6VhH7RT
	Ms1HCtu/Oz7ff5SLG8Yh8hfySX8UjFOGPTkxgqJTrfV5Tp6DunpuluMxfdxp3zLkv9g==
X-Received: by 2002:a63:88c7:: with SMTP id l190mr83324080pgd.244.1558458049283;
        Tue, 21 May 2019 10:00:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsh3FxiG3yT9hp7hGbc538isSTvrsUqrDX0bs6kkPk+lwFvh9gGiKfy1uDjQ2X0gf2PX8M
X-Received: by 2002:a63:88c7:: with SMTP id l190mr83323983pgd.244.1558458048470;
        Tue, 21 May 2019 10:00:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558458048; cv=none;
        d=google.com; s=arc-20160816;
        b=gTcLv+eRSLPq7nHdq812HTcV3cO3djHaCgdGnY/SjUWstSyCRKtecLkb2p8CBS74uB
         aev0QFLtn9C5vuME0nSF7rkjLTNiPo3sfbTf1v+vWRBBZAUKGODKVEEaJnhI29SsdDvt
         VA0yYmvoeITIEjv/UnXhMDn8I7p4M3zqsilFBM8wWg3tg9Y4WLDvJenhePA3O3RZTTcS
         ajrtmFiwKaZXB/BYLJdKVj8gDqRa7dn3RcCNNnbxqO17XBczebUJZdwQzX20gGGY1boz
         LVpPe/vaNMycnrFo/4s2opO/U5zneKzAowwsQQJqpOIkXjr3y/xCyqCHOgd6Np1bW+JI
         IW2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qs9NxSIsFhIUi5q0vuHy+yWUBymowMuQjy0VmUzDrB4=;
        b=g78R9JyZEp2rR4++mtjp10AHZ+tndv1OVvSgiSW3AQPTLjma5A5L694QjkfdB2PQ+A
         /Bsp0WphxixWGQpeD9cZo8336tFJMLcB6JVc6DLOoGqIjeMUw+r6QsKJq6it7CkCrwus
         TFmVbXQl69et+4aM1PU+ZkfEbgrBr09a0nGWE/8EKE6ksHW6Znli2gFhCHDkdo1LewgY
         4PEpSBCw+otEjg4K1Gwg5tqXBeqY05v0Ky0RItrqFUBRypUsoPQAjm4dHlmUsYVc6R2p
         UZdR91cmeO3Vb5tTnKWrMtRQebkuz/nhcQjFN8b+CsFKMC1wvjBMEx+tmlY7w4clPhG3
         kq2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0gl6NyxD;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u9si23578013pgq.44.2019.05.21.10.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 10:00:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=0gl6NyxD;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DC0FF2184B
	for <linux-mm@kvack.org>; Tue, 21 May 2019 17:00:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558458048;
	bh=9OojUtYA0LbZL0IhpfNco/9wKFwUCoXQNI7zcdJGSfw=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=0gl6NyxD+CezqGhCgUYDdISkwzLC9LT/TjqEDC7NKDw9fmLVIKRHEqm82nKW1csm3
	 cE0HjimltJnBGVQQdoffgyP2IJ0TiD9IKvWxA96cOBzK3d0lDx8aoxwEBAIBJs3fxW
	 /jGBD7ITYvyqevJV3g7a4BIzqpezsORPVZzudX8k=
Received: by mail-wr1-f53.google.com with SMTP id f8so13077684wrt.1
        for <linux-mm@kvack.org>; Tue, 21 May 2019 10:00:47 -0700 (PDT)
X-Received: by 2002:adf:f74a:: with SMTP id z10mr5273655wrp.291.1558458046385;
 Tue, 21 May 2019 10:00:46 -0700 (PDT)
MIME-Version: 1.0
References: <20190520233841.17194-1-rick.p.edgecombe@intel.com>
 <20190520233841.17194-3-rick.p.edgecombe@intel.com> <CALCETrUdfBrTV3kMjdVHv2JDtEOGSkVvoV++96x4zjvue0GpZA@mail.gmail.com>
 <4e353614f017c7c13a21d168992852dae1762aba.camel@intel.com>
In-Reply-To: <4e353614f017c7c13a21d168992852dae1762aba.camel@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 21 May 2019 10:00:34 -0700
X-Gmail-Original-Message-ID: <CALCETrXfnkLKv-jJzquj+547QWiwEBSxKtM3du3UqK80FNSSGg@mail.gmail.com>
Message-ID: <CALCETrXfnkLKv-jJzquj+547QWiwEBSxKtM3du3UqK80FNSSGg@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] vmalloc: Remove work as from vfree path
To: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Cc: "luto@kernel.org" <luto@kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"mroos@linux.ee" <mroos@linux.ee>, "redgecombe.lkml@gmail.com" <redgecombe.lkml@gmail.com>, 
	"mingo@redhat.com" <mingo@redhat.com>, "namit@vmware.com" <namit@vmware.com>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "Hansen, Dave" <dave.hansen@intel.com>, 
	"bp@alien8.de" <bp@alien8.de>, "davem@davemloft.net" <davem@davemloft.net>, 
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 9:51 AM Edgecombe, Rick P
<rick.p.edgecombe@intel.com> wrote:
>
> On Tue, 2019-05-21 at 09:17 -0700, Andy Lutomirski wrote:
> > On Mon, May 20, 2019 at 4:39 PM Rick Edgecombe
> > <rick.p.edgecombe@intel.com> wrote:
> > > From: Rick Edgecombe <redgecombe.lkml@gmail.com>
> > >
> > > Calling vm_unmap_alias() in vm_remove_mappings() could potentially
> > > be a
> > > lot of work to do on a free operation. Simply flushing the TLB
> > > instead of
> > > the whole vm_unmap_alias() operation makes the frees faster and
> > > pushes
> > > the heavy work to happen on allocation where it would be more
> > > expected.
> > > In addition to the extra work, vm_unmap_alias() takes some locks
> > > including
> > > a long hold of vmap_purge_lock, which will make all other
> > > VM_FLUSH_RESET_PERMS vfrees wait while the purge operation happens.
> > >
> > > Lastly, page_address() can involve locking and lookups on some
> > > configurations, so skip calling this by exiting out early when
> > > !CONFIG_ARCH_HAS_SET_DIRECT_MAP.
> >
> > Hmm.  I would have expected that the major cost of vm_unmap_aliases()
> > would be the flush, and at least informing the code that the flush
> > happened seems valuable.  So would guess that this patch is actually
> > a
> > loss in throughput.
> >
> You are probably right about the flush taking the longest. The original
> idea of using it was exactly to improve throughput by saving a flush.
> However with vm_unmap_aliases() the flush will be over a larger range
> than before for most arch's since it will likley span from the module
> space to vmalloc. From poking around the sparc tlb flush history, I
> guess the lazy purges used to be (still are?) a problem for them
> because it would try to flush each page individually for some CPUs. Not
> sure about all of the other architectures, but for any implementation
> like that, using vm_unmap_alias() would turn an occasional long
> operation into a more frequent one.
>
> On x86, it shouldn't be a problem to use it. We already used to call
> this function several times around a exec permission vfree.
>
> I guess its a tradeoff that depends on how fast large range TLB flushes
> usually are compared to small ones. I am ok dropping it, if it doesn't
> seem worth it.

On x86, a full flush is probably not much slower than just flushing a
page or two -- the main cost is in the TLB refill.  I don't know about
other architectures.  I would drop this patch unless you have numbers
suggesting that it's a win.

