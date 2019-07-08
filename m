Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35B8DC606BD
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:29:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 021D6216B7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 14:29:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 021D6216B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70CE58E0017; Mon,  8 Jul 2019 10:29:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BD788E0002; Mon,  8 Jul 2019 10:29:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AD738E0017; Mon,  8 Jul 2019 10:29:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 15BE88E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 10:29:47 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m2so1366070ljj.0
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 07:29:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=wbaTQs7XVTIjMbPZTFe9Yk64dlMj+blOtmWe+5amVKw=;
        b=WLCtlunTwqVASyuYeVrhID/ULgwLQ6xVzsdBc58nn0rUyHIz5jgBP3CoZisO3Rby3t
         XDPolCOfCOirH4kpwfzm6505H1YYcJ0ZsMG3x8wBgvceHGve3FyWhQIE6ojBzZFzHS5c
         VFrhhxqI/isDeUi1lwYJQDGygUh9qe/wLaZGioRlsWP11RtzW9H3UBZCKfdhqg7wJByI
         6Ct27BY1368F6wfLQQsmULk36wEIJyWan8ABYm2nUeGFeg1G8HzLQNuSB10BilvNfZq6
         uDagomDiU2bdTrjnL/RtxOl1KE4TTA1/pfmeQsMin2FldG8A6n/p24VG8Xnd2xJC4ylJ
         ilkg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAWoeYMboBft4+rplOVER+acYI3nikHgN53MJI63nzPs47YEZR1q
	xesdgMcBWP1YPfzjp0l3xrolDDK+TiuQF1HWl3gho1+u+tmc7gCRYnyQ30UCGpiT2crkkRB4CoK
	jI+Lfjfhe1saDgyw8ttFQvOSLNg6W9YLQNYE+BVNWZSMWKpX9T4wsQ1PrYmE5YCE=
X-Received: by 2002:a2e:959a:: with SMTP id w26mr10690292ljh.150.1562596186388;
        Mon, 08 Jul 2019 07:29:46 -0700 (PDT)
X-Received: by 2002:a2e:959a:: with SMTP id w26mr10690251ljh.150.1562596185458;
        Mon, 08 Jul 2019 07:29:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562596185; cv=none;
        d=google.com; s=arc-20160816;
        b=RqpfRC8h2TLAa8jQsSW2kwhW/dVi7u0fngbhIUkTjh9hs6Q8snc5rMgv4XdfCZJX2t
         9Q6/dQxudUlNmiFDKAlZ9mL2K5gME+S23rIXK0IHoKWezCWr4TE7Ao5y0J8XZeH+jQ3z
         XAPlpB7X4E+hYHkunEJPvbzg/B8sh2j6XJ1FE9bQt9wFlX0wO5GzQKOBiAJKPKUoS+ld
         X4RtjZtYQ1uiKLW/wRudfwq98KjlgBhtT04nClQkoiZdgVxlq9/drMuyrIMfZ21tdFR8
         ofy5s47wtsqC9dfttOT4JdawUTxd/2CVyeTOkJnaEKEmRVYAFqa37CNkum/xaY6zUO/V
         fjNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=wbaTQs7XVTIjMbPZTFe9Yk64dlMj+blOtmWe+5amVKw=;
        b=Vxl7QTxPKZc6uhOozTD1O8o7bUH66wSEV/5PwV/onQo7MWnfToxp6vTWRMnDxBYx3b
         Pj9Haf7cfBiQEy/KwC5zsnAhfZwdEqrkjZlwSSQPPLwf2OURZXeIiJZ8tayyskT6CYVO
         GciSB4D2ThPQ1pkraV6mGRVNBIqMhx8UNNcZS6AZ2qLcc/qQUdLYrJW0fVRPSV9HkXqy
         Iw19bxDnQ+oCYYCYE4vsqD+i1Fk8bvzeVwRjq/o4cG6k39DaQ/eYG8Gsa821q7wc/xYX
         Ay9eH7n2kSzKTzojzy3SmcHouWiaP1YCTUqSBFbFGSAJ/O59Wg6A3fUuHOEETO+e7bZo
         38YA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 134sor2748366lfh.33.2019.07.08.07.29.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 07:29:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqyqi6Z74FgeUmSY/fM6fHVQs+s4VIRWPGZo5CWIqN67oSsfVrFDvhr/it0wDG5JnxulzHk67f7NgX7txaM0q6Y=
X-Received: by 2002:ac2:46ce:: with SMTP id p14mr9177220lfo.148.1562596184914;
 Mon, 08 Jul 2019 07:29:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190707050058.CO3VsTl8T%akpm@linux-foundation.org>
In-Reply-To: <20190707050058.CO3VsTl8T%akpm@linux-foundation.org>
From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 8 Jul 2019 16:29:27 +0200
Message-ID: <CAK8P3a2KVPsX-3VZdVXAa1yAJDevMwQ9VQdx5j8tyMDydb76FQ@mail.gmail.com>
Subject: Re: mmotm 2019-07-06-22-00 uploaded
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Brown <broonie@kernel.org>, 
	Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Linux-Next Mailing List <linux-next@vger.kernel.org>, mhocko@suse.cz, mm-commits@vger.kernel.org, 
	Stephen Rothwell <sfr@canb.auug.org.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 7, 2019 at 7:05 AM <akpm@linux-foundation.org> wrote:

> * mm-move-mem_cgroup_uncharge-out-of-__page_cache_release.patch
> * mm-shrinker-make-shrinker-not-depend-on-memcg-kmem.patch
> * mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix.patch
> * mm-thp-make-deferred-split-shrinker-memcg-aware.patch

mm-shrinker-make-shrinker-not-depend-on-memcg-kmem-fix.patch fixes
the compile-time error when memcg_expand_shrinker_maps() is not
declared, but now we get a linker error instead because the
function is still not built into the kernel:

mm/vmscan.o: In function `prealloc_shrinker':
vmscan.c:(.text+0x328): undefined reference to `memcg_expand_shrinker_maps'

      Arnd

