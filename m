Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B24DC5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 16:27:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7B5D20828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 16:27:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="cOaWk12t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7B5D20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36BB66B0003; Fri, 28 Jun 2019 12:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 31D358E0003; Fri, 28 Jun 2019 12:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E59B8E0002; Fri, 28 Jun 2019 12:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id E96836B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:27:56 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id y81so2760673oig.19
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 09:27:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=1m5eUNW/8O3Uia+UgF1DOs7nZbA/5lPFN6ZbyXe0/Ls=;
        b=VtoOdBSpwpPl3faPlPOLw1kLqmN7WOql1ocLWy6wm2ffvecVCm6JCUJtDD4tG2Pd6t
         Cq5TJcBfTABLMldrmfYwJmPv5i2ucQQoAhGGTFpLqEgfyliwZ1oXs2xRXjbe7Bjc6T4y
         hk3BWApWwpSXwr4tuHnmcqwCo+eMMqfGfHK1Cnl/vY1MTSDw3MynkIkasfrkujWWCEkk
         4fcAH6ACynsz2sBZzM3zgsXaAcnx96/F9DNrb15BWt/p0JprvPrksGPe2oRIOZPkN/SP
         dVCMF6exhk+ZTY03ddsJVjAlNSg7D75gekLmYuCJEii5ZncMx2bsp/lHa6WjU/sGbuua
         qYdw==
X-Gm-Message-State: APjAAAXVcAthQuu1yQQiXAEkAiSimnGFR21vDiqHmNvJLIhujrkQ5f0Y
	E/i75ZD/nrNlirjg+n2X0FAXyuXVM3zzuyUSX/sxxSrjto6ueb/Sf93VRExHOqJATZ5E6jaspA9
	ziYUk+kD6MJrYfCaZasN1j+/sILYrY3PoBrQ2m8rKWWudbSZJ6cQTMTeORvAt3VRC8g==
X-Received: by 2002:a9d:6659:: with SMTP id q25mr8362184otm.272.1561739276589;
        Fri, 28 Jun 2019 09:27:56 -0700 (PDT)
X-Received: by 2002:a9d:6659:: with SMTP id q25mr8362137otm.272.1561739275832;
        Fri, 28 Jun 2019 09:27:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561739275; cv=none;
        d=google.com; s=arc-20160816;
        b=xLZ6EzbiLIOmvWID2nR1W/681WUANTcXehLsMDG7nWpb0YhSzsFw2BYKZmDsnBtodM
         6gH5TozXL5P945wxuKOHFCzNly+1Nbrw3dlqIH9nit1X7L6eNhNnuTJCCzVV1wpG+4rv
         hoFK9KxKKvpBew90OJIlerY+nYYWGRPTU+X/Vc5J4op+zeXmAGw4cizOaIYj7+3w2Kwz
         1bwLy+A96vno+Fh4DSeh9L519jfoZAFxrx/UHe5UveeONVrs5XdtDhcKyFZSq5ZNgfEy
         vaJ/WUuyRYMdK32tOWlz4Nu4UUndtnOhP2ZRNZ2lM9rSnqkrWdBkeUy0luvg3977v++k
         W0sQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=1m5eUNW/8O3Uia+UgF1DOs7nZbA/5lPFN6ZbyXe0/Ls=;
        b=hin6NIVadPj+9RRJkiQNv4nnLCgkgYSMIY2qflcCHDIG3T/jfTD1d69tnwckgfk1Px
         c72UdAugE+3OpJkoAevRuzzyMoraC2TRFuk8e7BygPie/jHb2+FmZhl4BkUyjov2t2cc
         JFGDz+Qnqcvr5HpaSCk7PCxk3sen9vvs617620JM03Rmb8dKDp8GhMT9eqfVpVVaUxFJ
         bP/Anp8qLtd3p4yEBhkN3dXRly1EEUel8pa+lcSih3ENuVP//1v51DBr1Nn64MgNmL9Y
         UGAZ1+DlFexaRkgCNYvMfQ3VKDT68s+UqTXKHfUAulNqoKTKA7gxDYKOld16ytnn6ppb
         5wHA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cOaWk12t;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 98sor1478808oti.90.2019.06.28.09.27.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Jun 2019 09:27:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=cOaWk12t;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=1m5eUNW/8O3Uia+UgF1DOs7nZbA/5lPFN6ZbyXe0/Ls=;
        b=cOaWk12t9PR+wM1gV05bVlfR0S1JSjfvb0hJ6JHo5ppfgDNgrz3BIflcx5b+w4agLb
         brYamehqIiFRGAjIKCUe6+Q53dn3hCuKVsdvquxg1/zCaxiJNgcnspoK9aZ9PKMXCUax
         piwsxxk5ZVG0/OrqNggRtsNENyTRYeAIsTv0w6rRIv8xEx0MB8nULTH+IB0NC3xJ3BeI
         w9h4nLRfPNokhqWP61aJrHtY0lfJBXalafI60Q5aBVAiBp99b8Xbt//EkmWeTAvVPTH8
         cyXy8F6iRDlqKv+0BbiPuN3y3R6N6GvMZWeSpv1agBiqh/rGomhhdkAUvQejKMcw69mS
         wn1A==
X-Google-Smtp-Source: APXvYqzpE+Kqyx1ivu95dqxD5Xmw+1dAtjgOIlYl2JIyAfPlIWR3aLAm88Jb4Ju/vM/swOByZ/3NEnMvyOQmHp503wY=
X-Received: by 2002:a9d:7248:: with SMTP id a8mr9100984otk.363.1561739275009;
 Fri, 28 Jun 2019 09:27:55 -0700 (PDT)
MIME-Version: 1.0
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-17-hch@lst.de>
 <20190628153827.GA5373@mellanox.com>
In-Reply-To: <20190628153827.GA5373@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 28 Jun 2019 09:27:44 -0700
Message-ID: <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 8:39 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Wed, Jun 26, 2019 at 02:27:15PM +0200, Christoph Hellwig wrote:
> > The functionality is identical to the one currently open coded in
> > device-dax.
> >
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > ---
> >  drivers/dax/dax-private.h |  4 ----
> >  drivers/dax/device.c      | 43 ---------------------------------------
> >  2 files changed, 47 deletions(-)
>
> DanW: I think this series has reached enough review, did you want
> to ack/test any further?
>
> This needs to land in hmm.git soon to make the merge window.

I was awaiting a decision about resolving the collision with Ira's
patch before testing the final result again [1]. You can go ahead and
add my reviewed-by for the series, but my tested-by should be on the
final state of the series.

[1]: https://lore.kernel.org/lkml/CAPcyv4gTOf+EWzSGrFrh2GrTZt5HVR=e+xicUKEpiy57px8J+w@mail.gmail.com/

