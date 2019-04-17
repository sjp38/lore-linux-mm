Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55D77C282DF
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:09:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 159EC20693
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:09:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="qxYyT4+3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 159EC20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A76B76B0005; Wed, 17 Apr 2019 18:09:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9FF516B0006; Wed, 17 Apr 2019 18:09:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EF606B0007; Wed, 17 Apr 2019 18:09:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5CC126B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 18:09:55 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 7so116137otj.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:09:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dbqIQjFBMMXB1QiDrqfCIlgRtfAJx8u+7/Kk91bmkDU=;
        b=d4C7JifjtVCOvtHyVbZlnEpkcpYqxrIQjRhUA2BDcAy419d3iO4R4t9g3IaT0rRID8
         J23zfkd+W4t7l+dLAsHTmWDcUSunkf79ZGcv487aVGN5RIBPw58tdeJ0JWYjyqOoSlkD
         Y2RsAwC4MnTrSQwgyNnqxgcXlmHZwyW6cBqQZuseWWuDBeqRGUddIMokUWg6rRxDiSSS
         0dQes9CNoaL3tPhEPq0SDrhayaZDgUR07cLtBmYM9m+6OjJNCIQVWXuhDjA6VG74GDmd
         9NBpRncXgSa/PQb+7cYhZgB4SRz8MnSDLaiNpPLJvm5hWpebUKqoPTuYfMKvyEghMQ0x
         DtVg==
X-Gm-Message-State: APjAAAU3a2uCPbMP1jfuarsXtEmdHGRbTMP7E0U73UpjRsvyEGoam5p6
	hw7tnTTyKh7/rVNLfflftfDWnpeqwrbRZkUFAXCr8Ol36mPXe/OL4OUKq6mwJhSlBII7Fe68nSp
	AtYHeV/TlLAACKaXdx6dLS5+OkY9hCQ4fEO7cs40WM2v608LHtaTSeOwMb7gR2s/T2g==
X-Received: by 2002:a9d:70cc:: with SMTP id w12mr50976260otj.167.1555538994955;
        Wed, 17 Apr 2019 15:09:54 -0700 (PDT)
X-Received: by 2002:a9d:70cc:: with SMTP id w12mr50976230otj.167.1555538994332;
        Wed, 17 Apr 2019 15:09:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538994; cv=none;
        d=google.com; s=arc-20160816;
        b=z69R2kw1daXt9T8B220i3za06/z5ucl5thOH4XOa4G1Bdem67u64aiUf32j/8rwnl8
         +D0QFjCAK+ivAcB7vXcyd5F6vsuVkFlODJy9jY68lMbcHs98fJBKyCn1Uu61YYyeslAf
         l2zbT5KNjx3y3Ep3wv6Edvn05YlKYUuvZE3sXtSVMbAj2cnLlDVbERNFBfQI6Ogo74Ew
         sWQ5Ija3Tlz4KKCbbpHgOJsnb3xnBw7u2g/M5yN2MN5wFnCIBMZ0GCWIQ5QWwqMSv9tI
         7sR8arkk96m2PGk4/f6JuF9jrcnPSAt9MlMWONbY0SKUFSQ753ogs8xWZMLLoKBSKKci
         oloQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dbqIQjFBMMXB1QiDrqfCIlgRtfAJx8u+7/Kk91bmkDU=;
        b=z1f4N8igzMm8tDf0AJ5T8LhSkBCRwebfyw+6UpMluu0i0MeTvQt27/ksnAR+gZZmoU
         KuMfg2aGUqGB3c/bAHJYKR8odUeVqxJOMjMWIIzwPYmx2l//ahEQLR9cx6Y7+g45UNp6
         E0PUp7e96H3nFdpmYotkiDhA/Y89Gr1w1tRRc7eHlzSt7lT7+zzJSBR5cwKuRo89k4HF
         zE6HFHk+OaB6sSVtf+34T8u6NEBEm6J2I+E4WI/9NBkJ4DfsFzXPa24bpZB+eT6eF+sE
         aK61evWjXvMs37y1lO3alFV5VsO/AgyDLy9nbVKm3LL216rFUSkzs6znRlGSXhPQLG9L
         pNVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qxYyT4+3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g4sor43894oif.125.2019.04.17.15.09.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 15:09:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=qxYyT4+3;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dbqIQjFBMMXB1QiDrqfCIlgRtfAJx8u+7/Kk91bmkDU=;
        b=qxYyT4+3M1kES1Z9MB2Bc+EJPmMxlo39ENZvj07r/1BFoWw3Gzizgk83iGo7ofBitO
         eSnkTptB3wyvaPBZVZS7vu6hUmkZDvrnrzhDfmmwWJduxQ7RySCGfmddd22RIbAi/XRq
         yZNnS2HSE46V8eFMepOGpn0AmC65T5+0Lg+mth0CJ//ZptXecCmfAzLvskzcxg5rDy5n
         RDKbGUzmwqce0+oIRr9rOKmuc1zzcK0gBZxxhcdY/3T6KtbZFldw6MrHriHslysr0OkG
         75uXpkOQRNGAYIuO1cgvKMm6VoxMITLmvb+25APghcgs6GjlpeWuK2Vb93ltPxYVROEM
         Cugw==
X-Google-Smtp-Source: APXvYqynMZNwDQfqs8yDEzntG4uXIuFy3zSkRRV7QtLiDk67MpPov0CvVUxNNEfuZQx8w4f3273kBnv/f1nGDvPrj04=
X-Received: by 2002:aca:e64f:: with SMTP id d76mr637171oih.105.1555538993969;
 Wed, 17 Apr 2019 15:09:53 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552639290.2015392.17304211251966796338.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190417150202.b7cec444cf81ed44a150ea9d@linux-foundation.org>
In-Reply-To: <20190417150202.b7cec444cf81ed44a150ea9d@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Apr 2019 15:09:42 -0700
Message-ID: <CAPcyv4jL4V=cV0rb=CYFDN=hs-1ETyH8JXJ2DOT3iB4UQemJXw@mail.gmail.com>
Subject: Re: [PATCH v6 11/12] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 3:02 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 17 Apr 2019 11:39:52 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > At namespace creation time there is the potential for the "expected to
> > be zero" fields of a 'pfn' info-block to be filled with indeterminate
> > data. While the kernel buffer is zeroed on allocation it is immediately
> > overwritten by nd_pfn_validate() filling it with the current contents of
> > the on-media info-block location. For fields like, 'flags' and the
> > 'padding' it potentially means that future implementations can not rely
> > on those fields being zero.
> >
> > In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> > section alignment, arrange for fields that are not explicitly
> > initialized to be guaranteed zero. Bump the minor version to indicate it
> > is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> > corruption is expected to benign since all other critical fields are
> > explicitly initialized.
> >
> > Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> > Cc: <stable@vger.kernel.org>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Buried at the end of a 12 patch series.  Should this be a standalone
> patch, suitable for a prompt merge?

It's not a problem unless a kernel implementation is explicitly
expecting those fields to be zero-initialized. I only marked it for
-stable in case some future kernel backports patch12. Otherwise it's
benign on older kernels that don't have patch12 since all fields are
indeed initialized.

