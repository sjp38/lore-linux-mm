Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 949F3C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:54:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C5052183F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 11:54:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C5052183F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD6C46B0008; Thu, 18 Apr 2019 07:54:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAE126B000A; Thu, 18 Apr 2019 07:54:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC6DA6B000C; Thu, 18 Apr 2019 07:54:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 81F866B0008
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 07:54:46 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e6so1888550wrs.1
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:54:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=LOgANvyzyMKmFS7vK2SQ+FqWR8dwhKrP+WoREASkiiI=;
        b=I85V/+s6b+xhQQ/4rT/8CHNrg8cYyoRxYil4UnWsNesQu5QzGFZOrPh2QmpTT2kKJs
         znwpw8t0zEOdqyx+/qsmQTnH/SrMxA+m0hX1mz3RumfGoIyJ68gkivVC+ak5MRXlV3fg
         6TlmbCuO4KBHKSA/MH4ZX537eHWTQI7crKmi6Y5H+dNsvJIjG+X13e8O9d50D/2mq4wW
         Ike8yr3u/DNqV0Sy9blfA9ZynazdBCT6Wbno8qX5wBm5Ur3eA9D6XipXBRcP6q38k24N
         AlEwpElJ5D8oOddG2AAE70Tor0B9XskE/koiWhvz9VQpRe4oEBFxvAjkt3SkKoApgzPl
         js0A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAU0CdrAhysVfnLX6zd0UfAl442r9jGf9QOb6Iz3AkcGBjptcfCi
	9Pa1JnB66Mprt/yzvACsT9v/rhqXrdSdwF8tcgnEShtJ68eoSO2SBq1MgFRT+vvCHNXYYnS1Gua
	UtizAu3PEqy2Xits4Hh8r90j4Iw2nKHEhPR/gDXjQxo1ictMpykWw602dFLvZXCRc0Q==
X-Received: by 2002:adf:df92:: with SMTP id z18mr55007533wrl.239.1555588486103;
        Thu, 18 Apr 2019 04:54:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyqCF6itwvSoFzR/dmT+qUHN9HsgTgkth3EGv+L57IW8/dyL/t4xY+e85w+Ga+FI1v3MXEY
X-Received: by 2002:adf:df92:: with SMTP id z18mr55007476wrl.239.1555588485221;
        Thu, 18 Apr 2019 04:54:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555588485; cv=none;
        d=google.com; s=arc-20160816;
        b=h6kSXsAFsO0gJ3P21rLgKAIefFd1k9q+LCsibDmSeoObKSFfOlB1tAJ3dYTaWiWnql
         vzezBujnn5RnuFuBPMPAljjknIN4Xl8e0TyN8AwcD5P9390bLkILtGu5WgU73elWtUNi
         IMPO39wGy3mkV2AtF03OxgQAF0YdyzD42Ky+/fBZmanZHf4NX5eXLeHTKs/Jahq8Jqm9
         ARhgYw+rNmIdX/OpSfVraXGFM2FCnQZxlP10rihQITLynaB5hxkhSWP3Cjy2h3WKkUUn
         Yof2qX3YUeq+jqlBJWk6YkIXRS1awJFuepK2u9QVMMjRU1uIU+0EFDuG3+IcgUcBDR6L
         GI2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=LOgANvyzyMKmFS7vK2SQ+FqWR8dwhKrP+WoREASkiiI=;
        b=EtHuwfHF9MInV6mIGHFcKRoGDbNLl+1baaLl+cEp+wPuwFzav5J/iFJD60437YJYgN
         dBjaTsIXH4zLeQQ0I3o1RdCeVmH2PvzOi6HpainWzqx32sOF8QjD+YGC0lyvrmDXofIC
         oC/z17LjL/ybOaafxyEAAhx/GaZgfBGeEUBg9gdyXThidYU04qXdx+hKjcxjSochTzUt
         dgZoFNc70tfuWGvh+QZuVapMlj0dn/qNZC3dLVsO48ElGXxeOPHF1P1RAqNFuDMGRJ6J
         rkPw72BwHbHVO7slZaCCjT0Yzz/jiDJDhlk3V552DbaAIMPT/dQhPArNkh3gc62KxEIJ
         yLlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h15si1459017wrx.148.2019.04.18.04.54.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 04:54:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hH5ck-00063t-VR; Thu, 18 Apr 2019 13:54:39 +0200
Date: Thu, 18 Apr 2019 13:54:37 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Alexander Potapenko <glider@google.com>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Steven Rostedt <rostedt@goodmis.org>, dm-devel@redhat.com, 
    Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
    Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, 
    Linux Memory Management List <linux-mm@kvack.org>, 
    David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, 
    kasan-dev <kasan-dev@googlegroups.com>, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org, 
    Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, 
    Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
    linux-btrfs@vger.kernel.org, intel-gfx@lists.freedesktop.org, 
    Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
    Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
    dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, 
    Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>, 
    Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 14/29] dm bufio: Simplify stack trace retrieval
In-Reply-To: <CAG_fn=WP9+bVv9hedoaTzWK+xBzedxaGJGVOPnF0o115s-oWvg@mail.gmail.com>
Message-ID: <alpine.DEB.2.21.1904181353420.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084254.361284697@linutronix.de> <CAG_fn=WP9+bVv9hedoaTzWK+xBzedxaGJGVOPnF0o115s-oWvg@mail.gmail.com>
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

On Thu, 18 Apr 2019, Alexander Potapenko wrote:
> On Thu, Apr 18, 2019 at 11:06 AM Thomas Gleixner <tglx@linutronix.de> wrote:
> > -       save_stack_trace(&b->stack_trace);
> > +       b->stack_len = stack_trace_save(b->stack_entries, MAX_STACK, 2);
> As noted in one of similar patches before, can we have an inline
> comment to indicate what does this "2" stand for?

Come on. We have gazillion of functions which take numerical constant
arguments. Should we add comments to all of them?

Thanks,

	tglx

