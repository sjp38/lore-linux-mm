Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 263A2C04AAF
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:43:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC8F420989
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 04:43:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Lt/DTI5w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC8F420989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E3266B0003; Thu,  9 May 2019 00:43:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16D446B0006; Thu,  9 May 2019 00:43:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0365F6B0007; Thu,  9 May 2019 00:43:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 920926B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 00:43:07 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id u6so189524lfi.5
        for <linux-mm@kvack.org>; Wed, 08 May 2019 21:43:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=e3NuoyA6DsdN8vS1rlRQd+bW+avLSVguOFGnQl9Uq1o=;
        b=sW1y25BDZWQQ74v5OgUQvMzzYe6/a3vFJaooRWmpUcOOfF0GOniVUbHVSMfgOQTjey
         UInH6OaBS0DTI3LW4aQpdVOYhURDMkI6ZPx8KinuYr9+mTG9UPdJ2G86w2ysCZu1WyUx
         CQJ90ygITgHVKl/X4i0PSoAnXm/VMn5mq1z1/5B31cTsMsH46SVm/PPnNsL5MGxRasWZ
         QH9Ru+vvoAV8fjTxQTGuD3J0V0K4JmmTzANrXiZ1bJWVcX+Uo8wU5mUzEFzvvoA1eiy4
         MCZkro6+ytsTe4RUqFrjrID9QP3BrxisFxrwH7c5BRk/oDpwNeUVeImGJPk+F5aubmiK
         AC4g==
X-Gm-Message-State: APjAAAUqo8rhDnBAqlcxq7lnF0ytIGhfr1Iza4Qrb27aWnX/key0ht4R
	NNuec+jrEJVw9mymo3bn0NNNsinX/XXaU//zpy2gfQLExbFY/5lfX+CnlNVR6Ls8xterVgOL+M7
	uosg82J2nCXTEzNzGKPbCaa5csIiUdie+kOvf++OPCCO8i5T3PJjfwgSQ0c82AbyNXw==
X-Received: by 2002:a2e:9e47:: with SMTP id g7mr853395ljk.48.1557376986733;
        Wed, 08 May 2019 21:43:06 -0700 (PDT)
X-Received: by 2002:a2e:9e47:: with SMTP id g7mr853353ljk.48.1557376985781;
        Wed, 08 May 2019 21:43:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557376985; cv=none;
        d=google.com; s=arc-20160816;
        b=K1khbPZrvrPiTHZ62dFqskmtS6lIGyTaFP+eUNmNyBgfEu0ezlWPf6VMj7MsLiAhGk
         36/TGIo86RVl7tcibvo9d8bXhCsc0XHN/gXXMs2xLvbi001HWbHTnHE0hEWMDfxs3E2+
         K+Kig8pPvhdbTCWp2pmyqYUlCmljv12q9kCVhZIaovyxKddm7/V2EweJqkiYCidOiDvM
         QgJMT55aNAl0aoC38J+Guf+1fQnJRZNaqGuA7tIajuihU+/wq2d0Cwhon+vJ77O8va4x
         wnG7tSg079Dq1Hj2RhJ2oqxq8zDi1QmNlATUYEtgxse2CQMTQodGWob+erJowIRCcK2+
         qyQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=e3NuoyA6DsdN8vS1rlRQd+bW+avLSVguOFGnQl9Uq1o=;
        b=0fV48aIQfx8FA0LExWL0hyXGONSs7oliFm5T8MsQW4OCjyvP2LbGZQ9rYzQIRAdwI+
         PNAA8n6PorbHLlcsR7H5F8ct6f4M+ySflvPCuu3IXvq1EQQyD4ej74WEGfp7K3gJm2+N
         5gGP2Ef+qjFtFtuZLL+6SEyfqLmyshlYFfnjMf2sT6oQ78EUMkI+jQIIcpdhUrZ4gFIF
         kuat5jRcqTw3VZNWF/3YuBgnwMBwVVPfKWg6c+BGYprsVVbw0ZZJSY3TkSOYuHWcDjHs
         n//xKH2igeBRwUlLyb/HSLcDHNuDFUw2sZ/Hd5FFntqN0fenRz3DLP2MyMyoUucU60Vr
         fCLw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Lt/DTI5w";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i16sor264677ljj.1.2019.05.08.21.43.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 May 2019 21:43:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Lt/DTI5w";
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=e3NuoyA6DsdN8vS1rlRQd+bW+avLSVguOFGnQl9Uq1o=;
        b=Lt/DTI5wNAIhQ/6m6siviyT/JhbAp3rvLyUD63xEOH2IAg2pMCbMTS5GVTmn+YjFEr
         pnlVWawZ4nlMIvBOt171hzqJoikbtkxHGB0/mAiy4+T0Rw2CoC2QP83rkkwOknkyTrVW
         IRuOvLBwGlgkRwVCBqoWuPwWjarfOB15lA5TfomCotP/1mkZgzE2vDNTJwjtVgAPyFrS
         MJpWxa//z66mbSVrM03P8D5yOr826PzQmL+znaT8rF9P0GSt8GxB25i3hV1aFx4c6bFG
         01Sw6nLVbznCBMk4a/bLRUHhV8ZEFJoUM3gjiFpUeSDeboJ9cpOKY0J2miFZ1Gf+wdk2
         AoeQ==
X-Google-Smtp-Source: APXvYqyahlAiHd3my+REndsaCdCPgpOP53l6bfy+BbUj2xIO/9159X2NF1ynIXXakgT60wBBaFKFYZTmcckc0FIv784=
X-Received: by 2002:a2e:7e0a:: with SMTP id z10mr855035ljc.9.1557376985164;
 Wed, 08 May 2019 21:43:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190506232942.12623-1-rcampbell@nvidia.com> <20190506232942.12623-5-rcampbell@nvidia.com>
 <CAFqt6zbhLQuw2N5-=Nma-vHz1BkWjviOttRsPXmde8U1Oocz0Q@mail.gmail.com> <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
In-Reply-To: <fa2078fd-3ec7-5503-94d7-c4d1a766029a@nvidia.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Thu, 9 May 2019 10:12:52 +0530
Message-ID: <CAFqt6zbL1r6+G6f-4-cpktyNZ929d4tNfQDt4oHXqeHoC9chHw@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, 
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, 
	Balbir Singh <bsingharora@gmail.com>, Dan Carpenter <dan.carpenter@oracle.com>, 
	Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 11:42 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
>
>
> On 5/7/19 6:15 AM, Souptick Joarder wrote:
> > On Tue, May 7, 2019 at 5:00 AM <rcampbell@nvidia.com> wrote:
> >>
> >> From: Ralph Campbell <rcampbell@nvidia.com>
> >>
> >> The helper function hmm_vma_fault() calls hmm_range_register() but is
> >> missing a call to hmm_range_unregister() in one of the error paths.
> >> This leads to a reference count leak and ultimately a memory leak on
> >> struct hmm.
> >>
> >> Always call hmm_range_unregister() if hmm_range_register() succeeded.
> >
> > How about * Call hmm_range_unregister() in error path if
> > hmm_range_register() succeeded* ?
>
> Sure, sounds good.
> I'll include that in v2.

Thanks.
>
> >>
> >> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> >> Cc: John Hubbard <jhubbard@nvidia.com>
> >> Cc: Ira Weiny <ira.weiny@intel.com>
> >> Cc: Dan Williams <dan.j.williams@intel.com>
> >> Cc: Arnd Bergmann <arnd@arndb.de>
> >> Cc: Balbir Singh <bsingharora@gmail.com>
> >> Cc: Dan Carpenter <dan.carpenter@oracle.com>
> >> Cc: Matthew Wilcox <willy@infradead.org>
> >> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> >> Cc: Andrew Morton <akpm@linux-foundation.org>
> >> ---
> >>   include/linux/hmm.h | 3 ++-
> >>   1 file changed, 2 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> >> index 35a429621e1e..fa0671d67269 100644
> >> --- a/include/linux/hmm.h
> >> +++ b/include/linux/hmm.h
> >> @@ -559,6 +559,7 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> >>                  return (int)ret;
> >>
> >>          if (!hmm_range_wait_until_valid(range, HMM_RANGE_DEFAULT_TIMEOUT)) {
> >> +               hmm_range_unregister(range);
> >>                  /*
> >>                   * The mmap_sem was taken by driver we release it here and
> >>                   * returns -EAGAIN which correspond to mmap_sem have been
> >> @@ -570,13 +571,13 @@ static inline int hmm_vma_fault(struct hmm_range *range, bool block)
> >>
> >>          ret = hmm_range_fault(range, block);
> >>          if (ret <= 0) {
> >> +               hmm_range_unregister(range);
> >
> > what is the reason to moved it up ?
>
> I moved it up because the normal calling pattern is:
>      down_read(&mm->mmap_sem)
>      hmm_vma_fault()
>          hmm_range_register()
>          hmm_range_fault()
>          hmm_range_unregister()
>      up_read(&mm->mmap_sem)
>
> I don't think it is a bug to unlock mmap_sem and then unregister,
> it is just more consistent nesting.

Ok. I think, adding it in change log will be helpful :)
>
> >>                  if (ret == -EBUSY || !ret) {
> >>                          /* Same as above, drop mmap_sem to match old API. */
> >>                          up_read(&range->vma->vm_mm->mmap_sem);
> >>                          ret = -EBUSY;
> >>                  } else if (ret == -EAGAIN)
> >>                          ret = -EBUSY;
> >> -               hmm_range_unregister(range);
> >>                  return ret;
> >>          }
> >>          return 0;
> >> --
> >> 2.20.1
> >>

