Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9BF1C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:14:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69393214C6
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:14:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69393214C6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D952E6B0005; Thu, 18 Apr 2019 17:14:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D44446B0006; Thu, 18 Apr 2019 17:14:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C32BB6B0007; Thu, 18 Apr 2019 17:14:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79A4E6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:14:57 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t82so3005049wmg.8
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:14:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=pu5Rj8hWThXw54he0+EkAkwFK8wyNsPrh/XUEtx10eE=;
        b=NTCvsTF01BWPfVWJDTa7FnZ6M7PYvpPEo785mcOUMryQvQCreu9w+bQcWJGPR6Ci2N
         dddJYmmkccEpR8gi1vje6F80G0OKSztsYN3RK9Sx82HekDNeZFR4KwutymBpTTGRQCEf
         108tHGNNJkbIa2bT6wLUdcFj/xBukwBPk9xsElLuo3l8OF7MG2DGtBgFrdOG8SJyIsDK
         V6L0ufjzrBvJIKAu1EhCv1GLiSmNnwNO2WqQb9vak99+/h4lbFSbKIEDKgHD4IkvckCZ
         Qm29XGBZLaTPblLVVvnGxUoQl1VADl7BNdAFgvmOBLDs+AygcrMf4vGTyy2CFzgSK0fh
         AQrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXFOrlsfkM7wBsRVa38Zx6hhY21U2VdVoYNM5Hzyj5BEa7T7S6G
	gsiB3j8mKRh4N1i15XH9fz6MH20Z0CRKJlF2BFSd9PKKEogdAhXT7UjziEj0l03jX7+p4iBBWDE
	SPBpRN4X4KB8HLxHV9NsEswMLNpuaIkj+GqqY+G5Pez6ugexXSbJvX4iITbRG9h+tvg==
X-Received: by 2002:a1c:c8:: with SMTP id 191mr235818wma.44.1555622096880;
        Thu, 18 Apr 2019 14:14:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYazipH2Ote0Ro/i9xtvx3CgWzxFLQ8TayrpVhvZF97KdXlsF/BiDVgK3F2pXR8kyKaHzG
X-Received: by 2002:a1c:c8:: with SMTP id 191mr235788wma.44.1555622096122;
        Thu, 18 Apr 2019 14:14:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555622096; cv=none;
        d=google.com; s=arc-20160816;
        b=r/ubi8UoQ2QhLMjXb/vb5PVZ7sF8QXeYiVNwhzDmLlcD7ZHoTxRyUYtG96l8Kfz5py
         b0tF3cx+DZ46eFch0gZ+pDKqCtzWB5w16NdLtloqU/1r7U+X2eogyWr8k9pbJOiK6cGT
         ig9PdcLSfRql/lJfZ/tj9Wi2nwfrdbBKwcRC9C1Wy7UiG8Y2SS2+t1twdwlbJyKEN3kW
         G2V/Sechuu/uuCmwXQI2rcASDTRPkDB0otZ+QLqmWARoIAjIrtjG/w/PPuFqvMCRmd0m
         JLfUTctIth1/Z57kNV5DwXrAfPY2qhbQl6Js8+uurVmU0wS0yseJIpcAAU5oWPj3hKvr
         LPfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=pu5Rj8hWThXw54he0+EkAkwFK8wyNsPrh/XUEtx10eE=;
        b=O0NT++r9VplvlqLk38qpk+WzYFVE/k8wHMnnQJylW95dxXV9Z+JcvNX/064U1dh6c3
         DyeWUc46EEunVNH7VBrjUEiBosKDyWc7NruwDkBPitRpPK0LJuJVZjh1MDuCfzrctQAN
         28PvXV5dxRbCamG/7XX92VapcCJvlNSBxdDmZ4gZjf0G+UiOviJ7n7W390HzGCCxilaC
         PBc4chM8JdFMhrr7WpfwKn7qkXvDcXs/GQ/vkI5hZjCiEBi3Omef3QHzPygalmDsF1N0
         JI1FtP1d3h1udr+qnzo3PeRQt1QNRhc1obAoHUjmdsrqCbnM0R7suMVsfcDk49SDSuQC
         vBIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h8si306240wrr.91.2019.04.18.14.14.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 18 Apr 2019 14:14:56 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hHEMp-0006bb-27; Thu, 18 Apr 2019 23:14:47 +0200
Date: Thu, 18 Apr 2019 23:14:45 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Josh Poimboeuf <jpoimboe@redhat.com>
cc: LKML <linux-kernel@vger.kernel.org>, x86@kernel.org, 
    Andy Lutomirski <luto@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
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
Subject: Re: [patch V2 01/29] tracing: Cleanup stack trace code
In-Reply-To: <20190418135721.5vwd6ngxagrrrrtt@treble>
Message-ID: <alpine.DEB.2.21.1904182313470.3174@nanos.tec.linutronix.de>
References: <20190418084119.056416939@linutronix.de> <20190418084253.142712304@linutronix.de> <20190418135721.5vwd6ngxagrrrrtt@treble>
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

On Thu, 18 Apr 2019, Josh Poimboeuf wrote:

> On Thu, Apr 18, 2019 at 10:41:20AM +0200, Thomas Gleixner wrote:
> > - Remove the extra array member of stack_dump_trace[]. It's not required as
> >   the stack tracer stores at max array size - 1 entries so there is still
> >   an empty slot.
> 
> What is the empty slot used for?

I was trying to find an answer but failed. Maybe it's just historical
leftovers or Steven knows where the magic is in this maze.

Thanks,

	tglx

