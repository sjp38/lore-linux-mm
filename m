Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527CEC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 20:32:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A5E6206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 20:32:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A5E6206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D6A66B0005; Wed, 17 Apr 2019 16:32:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95F276B0006; Wed, 17 Apr 2019 16:32:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 82A426B0007; Wed, 17 Apr 2019 16:32:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0626B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:32:39 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z24so53199qto.7
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:32:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=8oT1njRJkluIBbzQIshYTKMhjNIBlt3uGMXUeeJW/Rs=;
        b=No4KdsX/aurGJC3wQJF86KXe2Kdc57ZevsrtyArv7aVRwFwdmraYmqgfqWtTAalWrf
         l4/s7zaOPI2Qbu3MSLJq3g9MhG2G442fnOGE+mggzBYR/NUGNC61gFdzhRXwEMsQFHCp
         zr4ZOA45ISdMsLsRTeVNzrJCNMw3PvOyQ3CDjNN2bZMQppSWdGmW+aQo96HmNC01YIlG
         MCzS881TbuoMkKXDUpcyGzmQkl7wtPcKo7B/QGTEf3ta5toL9O+0loSoSD0mJ/9ztDPd
         b4MfR7RTPHLPgkf9+kQ87yLvRZYf1JKm0h0Qo/VywST75fdcgSL0JWZbdQc1+R5NSinU
         HXkQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWvf4SWofrqu9VTcH7caOSpOMTTWJACGBcKYKBdBYl9iT6TE/2K
	L/+Wq8L+SCgrnq+I3eMrwbrpTjJMYt7JdZazoyl3THVJIMdy+ap58ZRIG/Uud0tXSQCmQGD0IEG
	oVsUguRUCcVTCeqckwoUPw0GC+CL7+hkX/UDSzH+ZyovSZHuw6H3gtCmhI5qigx02GQ==
X-Received: by 2002:a37:a951:: with SMTP id s78mr70857280qke.156.1555533159056;
        Wed, 17 Apr 2019 13:32:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzzWJ7srijIcV/HzsEpWt6NNymk7rQb8spqo58J48r0xs03qe9DbuLQ+h2ty6vxySsSHz1J
X-Received: by 2002:a37:a951:: with SMTP id s78mr70857233qke.156.1555533158407;
        Wed, 17 Apr 2019 13:32:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555533158; cv=none;
        d=google.com; s=arc-20160816;
        b=jSmiOmyL9sMOBeXx1BjOFDiKHN9uZvIKf78sXgZWt0mlUIGxPKST2L1T9XahXqqMNE
         ksgid7i/eh7Vb8Ddg4B55u6JdYquI2z5UC1RG9z917ymiCiOvucq9EYWXa1pLq078CVN
         elz8rKcNsiihIkbgCW9XOW8I2ejACkkEkJKG0tZI2Frg2g9nJTPlYm6ArKHr+QdTgCeh
         zgXODrXA68kjiDFD5+iVPfVsIr3ud04KoOvnsQKAnYUUyWG+GvN4sVRkcEn6+mZNptoy
         GHWVdADXIgEpUP4+U/uT11XA1sDpxkuIT0RMOxoD4++Z+8DsWkgfratWv6VJwROLIjD/
         bPMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=8oT1njRJkluIBbzQIshYTKMhjNIBlt3uGMXUeeJW/Rs=;
        b=hBotD6W8zblirCSGBAAh6o9PHkJxGc/I0KXM9TuNzPVsnFkHj75z+MH+QOCaKfA5b7
         WqOMNSsyUV4TgZNIu6JF9txYsNdft8UWQi7giNcIf/fuvBhUdTi1C7ADF4UgSvRra+8v
         BwvEVKyK5N0eKV1mb1RuVqe3OV4ejNN8+HhyQ9YRqDkpO3ylUnZbsaz6oR2VqtvfsKY4
         mK61gL0cAZP8b6mFBgSxgGzWybbFOYubsZ+GwaqgMtM+nror8ZP93o0n8nlNP6KAtkYM
         CAaj2L1/GYmrEcCrJmcvshbK/pEUG2oojWWuFKQ46pjvd8/+Mz4orKgi3BWqq4JM4GQ1
         LFLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c21si38541qvc.139.2019.04.17.13.32.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 13:32:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AEB130ADBCE;
	Wed, 17 Apr 2019 20:32:37 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 57BCD5D9D6;
	Wed, 17 Apr 2019 20:32:36 +0000 (UTC)
Date: Wed, 17 Apr 2019 16:32:34 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Leon Romanovsky <leonro@mellanox.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH] mm/hmm: kconfig split HMM address space mirroring from
 device memory
Message-ID: <20190417203234.GA3409@redhat.com>
References: <20190411180326.18958-1-jglisse@redhat.com>
 <20190417182118.GA1477@roeck-us.net>
 <20190417182618.GA11499@redhat.com>
 <20190417193335.GA23825@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417193335.GA23825@roeck-us.net>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Wed, 17 Apr 2019 20:32:37 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 12:33:35PM -0700, Guenter Roeck wrote:
> On Wed, Apr 17, 2019 at 02:26:18PM -0400, Jerome Glisse wrote:
> > On Wed, Apr 17, 2019 at 11:21:18AM -0700, Guenter Roeck wrote:
> > > On Thu, Apr 11, 2019 at 02:03:26PM -0400, jglisse@redhat.com wrote:
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > 
> > > > To allow building device driver that only care about address space
> > > > mirroring (like RDMA ODP) on platform that do not have all the pre-
> > > > requisite for HMM device memory (like ZONE_DEVICE on ARM) split the
> > > > HMM_MIRROR option dependency from the HMM_DEVICE dependency.
> > > > 
> > > > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > > > Cc: Leon Romanovsky <leonro@mellanox.com>
> > > > Cc: Jason Gunthorpe <jgg@mellanox.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > > Tested-by: Leon Romanovsky <leonro@mellanox.com>
> > > 
> > > In case it hasn't been reported already:
> > > 
> > > mm/hmm.c: In function 'hmm_vma_handle_pmd':
> > > mm/hmm.c:537:8: error: implicit declaration of function 'pmd_pfn'; did you mean 'pte_pfn'?
> > 
> > No it is pmd_pfn
> > 
> FWIW, this is a compiler message.
> 
> > > 
> > > and similar errors when building alpha:allmodconfig (and maybe others).
> > 
> > Does HMM_MIRROR get enabled in your config ? It should not
> > does adding depends on (X86_64 || PPC64) to ARCH_HAS_HMM
> > fix it ? I should just add that there for arch i do build.
> > 
> 
> The eror is seen with is alpha:allmodconfig. "make ARCH=alpha allmodconfig".
> It does set CONFIG_ARCH_HAS_HMM=y.
> 
> This patch has additional problems. For arm64:allmodconfig
> and many others, when running "make ARCH=arm64 allmodconfig":
> 
> WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
>   Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
>   Selected by [m]:
>   - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=m] && STAGING [=y]
> 
> WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
>   Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
>   Selected by [m]:
>   - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=m] && STAGING [=y]
> 
> WARNING: unmet direct dependencies detected for DEVICE_PRIVATE
>   Depends on [n]: ARCH_HAS_HMM_DEVICE [=n] && ZONE_DEVICE [=n]
>   Selected by [m]:
>   - DRM_NOUVEAU_SVM [=y] && HAS_IOMEM [=y] && ARCH_HAS_HMM [=y] && DRM_NOUVEAU [=m] && STAGING [=y]
> 
> This in turn results in:
> 
> arch64-linux-ld: mm/memory.o: in function `do_swap_page':
> memory.c:(.text+0x798c): undefined reference to `device_private_entry_fault'
> 
> not only on arm64, but on other architectures as well.
> 
> All those problems are gone after reverting this patch.
> 
> Guenter

Andrew let drop this patch i need to fix nouveau Kconfig first.

Cheers,
Jérôme

