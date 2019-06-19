Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7977FC31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:36:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1987B20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 13:36:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="VYCcHZtb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1987B20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98AF66B0003; Wed, 19 Jun 2019 09:36:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93C1D8E0002; Wed, 19 Jun 2019 09:36:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8039C8E0001; Wed, 19 Jun 2019 09:36:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E2636B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 09:36:36 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so15855969qte.8
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 06:36:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=t61WR0b8q8ztOgV4lVfs09XyRVW1yx3lBgFpQseYXFQ=;
        b=Dv4q7L7sILROlG2ppwrxakyW2rM99k/CIkSmVEYgPlZWsjGLXzNNSsVtN/+b2Fig3n
         qLzFqKGSAJhwG9SDLAB1GzwbmoP8XNl7jRUgyagQ8wrHuUn4Hfa0kxJr69viA2OtAuNl
         Pcq+cupnV/cT+mqaQqQ/m0A5iOvio9g/zG1+jHOOs+RVXduqLaYYMF5ld3eJuxlSaleS
         kvuNG5OeFatKvRvWyTHjHiZRcoJR4kLxrsRIJyT8D9basprLPihG96cfW5UGOyR/f1ef
         CCetiJx4xg+16wPLxE9xmt5eFPp2oxQMwqhtUYlrQly+6pH9Az8Ld9XYwtLaJdGfpmko
         vOKA==
X-Gm-Message-State: APjAAAVODkS1egAz6da/YOF/SLbGzd+Twh/E6T393Uq6VvdIidx3cprs
	AvJIQ9K73L6gVlHdF9Oja+bh9cVudES2++QjK1eEW5LfuFRdZR+Dub9Q/AA+qm3FhKLN56oMS8z
	3NvXnir/tHyFctZTXRIZPC5BOa/T98WLDSSfYmpthU+Kp5lqNQw2+WSrxibfEBUDhpQ==
X-Received: by 2002:ac8:3fb3:: with SMTP id d48mr106229320qtk.290.1560951396100;
        Wed, 19 Jun 2019 06:36:36 -0700 (PDT)
X-Received: by 2002:ac8:3fb3:: with SMTP id d48mr106229226qtk.290.1560951395088;
        Wed, 19 Jun 2019 06:36:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560951395; cv=none;
        d=google.com; s=arc-20160816;
        b=i61ad67Mv0lJBDPGg1zezqc7H5fFHfSl+5G33b+pPYUsJfrFh/KHHLZuhxMledAjGR
         gjFr0UkA32tYtXrsWBQSzIKCMot0BcZ8BZFpxfYsbMZvkgT7zk1QU8jjydiTFuKsgar+
         BCb4GqbQ5LRdhHET82QMVgMfF8yFSEjcttT44+qZMLOHtsaYh6O59YVwTJCp6N9m9hEM
         r3fqT6Y5pnEJDPo5WY66z84ltnLhR8lOzbNNij8yF6F7Bn5UxqBWGxWnxRibnV1BT1Yq
         Tdp0C0+fgrgpuadvpHK0oZleLZ2u4vwrA1tslp5mTalszYTcfOXPblJLdMdkxSfZ36yq
         IieA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=t61WR0b8q8ztOgV4lVfs09XyRVW1yx3lBgFpQseYXFQ=;
        b=TzxmjlhN79QYKFz0+EDtT46RSNUmNR4sA/rbTRrXVqFFOzyoWXQqsiCYwzYy3oAa1K
         4OItBdTV0ZpayooJfBt3wZK+jzIsQXffu8gyGkeYgSsYqMAslZjGwb0gO3GFvHHni6lo
         2d5HDwTr2Tb+RC0104DS6nDbACOw+eV/dWjdi0FBc+61VKYtFmQe1AGcudSc2xSVrTqe
         nFCqxD+Fvp9OjI0F53VVK3l/DiRr5b0UmtF+C6WqJYGhALPPmj/AmoGi+GJ4UIQgTVVp
         oZeOpqiyaGtPYBFAlFTsPYW63KzsyZ63EPhKAadvMAW9FnY5tzhy0tCpCUXQg06gjhbJ
         thjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=VYCcHZtb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor15748091qvt.72.2019.06.19.06.36.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 06:36:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=VYCcHZtb;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=t61WR0b8q8ztOgV4lVfs09XyRVW1yx3lBgFpQseYXFQ=;
        b=VYCcHZtb0Rik1j3811ujVQiuYJypPuJjK+nNwjZs75YFsasWyrjNpaoZ+Zq1NBSoA9
         XLJA+0/s6P98/FpJYqptmehrYqkB9/A4OyYHSSEGPUf1nxRxP/FpwIFtkoPMRgzJEsZ8
         EEDS6TWO5yduQgMcKL7qXBVwVy8cuYOKNGZciOP1WpL7lAsPhcXx0WrOYf+1E7uKG+8i
         uyGKwna7IhbKI5Z4ijU1zq+aUL8YgnW1oa+B0XN/ed+2S34wGOYlyjLlm15RwOiRbEWS
         CzXaOWB4s8EaI5AmWCexsRi8L10clYqluUFjpfFlpFr5FVRNoHFfBa9TMiKGxbe3LQlp
         Mwkw==
X-Google-Smtp-Source: APXvYqwD82znYg6F7UKwo8mAyCvDkNtthoyNB6hTdlh35ghpKITXxM7dtnwMxggvx2OqQUltsLBOig==
X-Received: by 2002:a0c:aed0:: with SMTP id n16mr33860879qvd.101.1560951394481;
        Wed, 19 Jun 2019 06:36:34 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id c5sm7986594qtj.27.2019.06.19.06.36.33
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 06:36:33 -0700 (PDT)
Message-ID: <1560951392.5154.29.camel@lca.pw>
Subject: Re: "mm: reparent slab memory on cgroup removal" series triggers
 SLUB_DEBUG errors
From: Qian Cai <cai@lca.pw>
To: Roman Gushchin <guro@fb.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton
 <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel
 Mailing List <linux-kernel@vger.kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>
Date: Wed, 19 Jun 2019 09:36:32 -0400
In-Reply-To: <20190619030940.GA17244@castle.DHCP.thefacebook.com>
References: <65CAEF0C-F2A3-4337-BAFB-895D7B470624@lca.pw>
	 <20190619030940.GA17244@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-19 at 03:09 +0000, Roman Gushchin wrote:
> On Tue, Jun 18, 2019 at 05:43:04PM -0400, Qian Cai wrote:
> > Booting linux-next on both arm64 and powerpc triggers SLUB_DEBUG errors
> > below. Reverted the whole series “mm: reparent slab memory on cgroup
> > removal” [1] fixed the issue.
> 
> Hi Qian!
> 
> Thank you for the report!
> 
> Didn't you try to reproduce it on x86? All the code changed in this series
> isn't arch-specific, so if it can be seen only on ppc and arm64, that's
> interesting.

Yes, it is not reproducible on x86 yet.

> 
> I'm currently on PTO and have a very limited internet connection,
> so I won't be able to reproduce the issue up to Sunday, when I'll be back.
> 
> If you can try reverting only the last patch from the series,
> I will appreciate it.

No, that does not help.

> 
> Thanks!
> 
> > 
> > [1] https://lore.kernel.org/lkml/20190611231813.3148843-1-guro@fb.com/
> > 
> > [  151.773224][ T1650] BUG kmem_cache (Tainted: G    B   W        ): Poison
> > overwritten
> > [  151.780969][ T1650] ---------------------------------------------------
> > --------------------------
> > [  151.780969][ T1650] 
> > [  151.792016][ T1650] INFO: 0x000000001fd6fdef-0x0000000007f6bb36. First
> > byte 0x0 instead of 0x6b
> > [  151.800726][ T1650] INFO: Allocated in create_cache+0x6c/0x1bc age=24301
> > cpu=97 pid=1444
> > [  151.808821][ T1650] 	kmem_cache_alloc+0x514/0x568
> > [  151.813527][ T1650] 	create_cache+0x6c/0x1bc
> > [  151.817800][ T1650] 	memcg_create_kmem_cache+0xfc/0x11c
> > [  151.823028][ T1650] 	memcg_kmem_cache_create_func+0x40/0x170
> > [  151.828691][ T1650] 	process_one_work+0x4e0/0xa54
> > [  151.833398][ T1650] 	worker_thread+0x498/0x650
> > [  151.837843][ T1650] 	kthread+0x1b8/0x1d4
> > [  151.841770][ T1650] 	ret_from_fork+0x10/0x18
> > [  151.846046][ T1650] INFO: Freed in slab_kmem_cache_release+0x3c/0x48
> > age=23341 cpu=28 pid=1480
> > [  151.854659][ T1650] 	slab_kmem_cache_release+0x3c/0x48
> > [  151.859799][ T1650] 	kmem_cache_release+0x1c/0x28
> > [  151.864507][ T1650] 	kobject_cleanup+0x134/0x288
> > [  151.869127][ T1650] 	kobject_put+0x5c/0x68
> > [  151.873226][ T1650] 	sysfs_slab_release+0x2c/0x38
> > [  151.877931][ T1650] 	shutdown_cache+0x198/0x23c
> > [  151.882464][ T1650] 	kmemcg_cache_shutdown_fn+0x1c/0x34
> > [  151.887691][ T1650] 	kmemcg_workfn+0x44/0x68
> > [  151.891963][ T1650] 	process_one_work+0x4e0/0xa54
> > [  151.896668][ T1650] 	worker_thread+0x498/0x650
> > [  151.901113][ T1650] 	kthread+0x1b8/0x1d4
> > [  151.905037][ T1650] 	ret_from_fork+0x10/0x18
> > [  151.909324][ T1650] INFO: Slab 0x00000000406d65a6 objects=64 used=64
> > fp=0x000000004d988e71 flags=0x7ffffffc000200
> > [  151.919596][ T1650] INFO: Object 0x0000000040f4b79e
> > @offset=15420325124116637824 fp=0x00000000e038adbf
> > [  151.919596][ T1650] 
> > [  151.931079][ T1650] Redzone 00000000fc4c04f0: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  151.941168][ T1650] Redzone 000000009a25c019: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  151.951256][ T1650] Redzone 000000000b05c7cc: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  151.961345][ T1650] Redzone 00000000a08ae38b: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  151.971433][ T1650] Redzone 00000000e0eccd41: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  151.981520][ T1650] Redzone 0000000016ee2661: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  151.991608][ T1650] Redzone 000000009364e729: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  152.001695][ T1650] Redzone 00000000f2202456: bb bb bb bb bb bb bb bb bb
> > bb bb bb bb bb bb bb  ................
> > [  152.011784][ T1650] Object 0000000040f4b79e: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.021783][ T1650] Object 000000002df21fec: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.031779][ T1650] Object 0000000041cf0887: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.041775][ T1650] Object 00000000bfb91e8f: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.051770][ T1650] Object 00000000da315b1c: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.061765][ T1650] Object 00000000b362de78: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.071761][ T1650] Object 00000000ad4f72bf: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.081756][ T1650] Object 00000000aa32d346: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.091751][ T1650] Object 00000000ad1cf22c: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.101746][ T1650] Object 000000001cee47e4: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.111741][ T1650] Object 00000000418720ed: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.121736][ T1650] Object 00000000dee1c3f2: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.131731][ T1650] Object 00000000a23397c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.141727][ T1650] Object 000000002ed01641: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.151721][ T1650] Object 00000000915ec720: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.161716][ T1650] Object 00000000915988c1: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.171711][ T1650] Object 000000004a0cc60f: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.181707][ T1650] Object 0000000054a294c9: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.191701][ T1650] Object 0000000054f61682: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.201697][ T1650] Object 0000000018d04328: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.211692][ T1650] Object 00000000703cf2c7: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.221687][ T1650] Object 000000004d3ac5d5: 6b 6b 6b 6b 6b 6b 6b 6b 00
> > 00 00 00 00 00 00 00  kkkkkkkk........
> > [  152.231682][ T1650] Object 00000000726ce587: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.241676][ T1650] Object 00000000c709b64e: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.251672][ T1650] Object 0000000044d6a5c6: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.261667][ T1650] Object 000000009c76a6a2: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.271662][ T1650] Object 0000000033d01d12: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.281657][ T1650] Object 00000000c50ff26f: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.291652][ T1650] Object 00000000ebc3aaae: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.301647][ T1650] Object 00000000a2072fe3: 6b 6b 6b 6b 6b 6b 6b 6b 6b
> > 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
> > [  152.311641][ T1650] Object 000000003d5911a3: 6b 6b 6b 6b 6b 6b 6b
> > a5                          kkkkkkk.
> > [  152.320942][ T1650] Redzone 000000009a2feac1: bb bb bb bb bb bb bb
> > bb                          ........
> > [  152.330330][ T1650] Padding 00000000c1b3cb8b: 5a 5a 5a 5a 5a 5a 5a 5a 5a
> > 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> > [  152.340412][ T1650] Padding 000000003715421a: 5a 5a 5a 5a 5a 5a 5a 5a 5a
> > 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> > [  152.350493][ T1650] Padding 0000000066b51ba7: 5a 5a 5a 5a 5a 5a 5a 5a 5a
> > 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> > [  152.360575][ T1650] Padding 00000000ca240306: 5a 5a 5a 5a 5a 5a 5a 5a 5a
> > 5a 5a 5a 5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
> > [  152.370657][ T1650] Padding 0000000014a2af5d: 5a 5a 5a 5a 5a 5a 5a
> > 5a                          ZZZZZZZZ
> > [  152.380048][ T1650] CPU: 82 PID: 1650 Comm: kworker/82:1 Tainted:
> > G    B   W         5.2.0-rc5-next-20190617 #18
> > [  152.390216][ T1650] Hardware name: HPE Apollo
> > 70             /C01_APACHE_MB         , BIOS L50_5.13_1.0.9 03/01/2019
> > [  152.400741][ T1650] Workqueue: memcg_kmem_cache
> > memcg_kmem_cache_create_func
> > [  152.407786][ T1650] Call trace:
> > [  152.410926][ T1650]  dump_backtrace+0x0/0x268
> > [  152.415280][ T1650]  show_stack+0x20/0x2c
> > [  152.419287][ T1650]  dump_stack+0xb4/0x108
> > [  152.423384][ T1650]  print_trailer+0x274/0x298
> > [  152.427825][ T1650]  check_bytes_and_report+0xc4/0x118
> > [  152.432959][ T1650]  check_object+0x2fc/0x36c
> > [  152.437312][ T1650]  alloc_debug_processing+0x154/0x240
> > [  152.442532][ T1650]  ___slab_alloc+0x710/0xa68
> > [  152.446972][ T1650]  kmem_cache_alloc+0x514/0x568
> > [  152.451672][ T1650]  create_cache+0x6c/0x1bc
> > [  152.455938][ T1650]  memcg_create_kmem_cache+0xfc/0x11c
> > [  152.461158][ T1650]  memcg_kmem_cache_create_func+0x40/0x170
> > [  152.466814][ T1650]  process_one_work+0x4e0/0xa54
> > [  152.471515][ T1650]  worker_thread+0x498/0x650
> > [  152.475953][ T1650]  kthread+0x1b8/0x1d4
> > [  152.479872][ T1650]  ret_from_fork+0x10/0x18
> > [  152.484139][ T1650] FIX kmem_cache: Restoring 0x000000001fd6fdef-
> > 0x0000000007f6bb36=0x6b
> > [  152.484139][ T1650] 
> > [  152.494395][ T1650] FIX kmem_cache: Marking all objects used

