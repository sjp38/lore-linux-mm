Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 954D7C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:50:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59DCC21881
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:50:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59DCC21881
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=alum.mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF5E08E000D; Wed,  3 Jul 2019 13:50:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA7498E0001; Wed,  3 Jul 2019 13:50:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C94708E000D; Wed,  3 Jul 2019 13:50:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9388A8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:50:57 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 21so733403wmj.4
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:50:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=hndznlvzR7hCc155DH4EmepiersU9zF+O4Q02wI0fg0=;
        b=N76jlKoQQ9MQC7ODpAVAc7UFRpnuY4cxTgBi/AXCfl0KLBdzaH4bh+lV+9ISeHxzvg
         YeutOmFEJ9DkgzIiZGWu/cxwzqFFCUuSzuaMU40QAAuRNy91UdO0lRAb0T5UfEtGDiIp
         da/bl7PwjcyoANb1O2yvms3XzP9ERho6IaLjvfIzcFWBlXIJU0h6OJlydMCec6hmSf/t
         MjrHEdmVpcCR5/gD4mjH9i6UHSQtEGD/pXSFZ0M7ExiGoxNEjiLcH3cySwMdPxBrLoKX
         UTj+M9dPEHCSYsAPGtLIkUrDbcisfQIi9n0pwlG5+BuNQYHKA28SsEROkc2X3vsgl5hz
         Wrjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ibmirkin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ibmirkin@gmail.com
X-Gm-Message-State: APjAAAW/MMywMhnpN7OGRUq7D8mvr3STv0d+ZNNzt5H7yaJsx0LtRffL
	kiNmhf5x4FqD+CTDQTUEvOCST1ftqb3QDmLIrD0BFWAxAuQPIbhermz4hzD7tk2mMyAV/modTUF
	RhWME2EXqz13d+rzoXLy+OMJw58r9OsWDAC1DYlaL9F/xXnanXvV4W0u/drT4i1w=
X-Received: by 2002:a1c:b782:: with SMTP id h124mr8785880wmf.20.1562176257197;
        Wed, 03 Jul 2019 10:50:57 -0700 (PDT)
X-Received: by 2002:a1c:b782:: with SMTP id h124mr8785858wmf.20.1562176256547;
        Wed, 03 Jul 2019 10:50:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562176256; cv=none;
        d=google.com; s=arc-20160816;
        b=j38UADP+5/Ow1c1BOilkOQVZ69qMWO3Dc5I5VU2ecrWD2TqBWKrRnKrSbNaolV4cbj
         0hUuek/HmAYxIr9jqgkFXgLLKvlEVeTqYNF424lHRrX3ONQ0/X3CgTNz60h6+gr+pOA3
         sQt5ltHFePhUKOtS4EBhfvPgzIHjITzyWQakYCPZ49WEC7trzaUP4MVYcRMZ9m0r0s6Q
         Z+jG7V+Zg1k1ECia2/xNeJuc/D/+Xb22TwSiIRn+dJl5bYojk/5LI4ZSvsqmug8B5mrP
         Y0KhkgMn7H2ZR0dKa+d32O3B6HkcBJj0Ybz91otKGK5zC/zl8vXNp7IKhGkawOGCT2iQ
         kf4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=hndznlvzR7hCc155DH4EmepiersU9zF+O4Q02wI0fg0=;
        b=vgiYkPDKMmz40KTB2fvAx5GcPG1fLu9Gsy0Q6Atz7egg+OnjeUcfpeY656JNu3trk9
         /3yFtsIAHSS0Mrgi6uwXSEibjLdchsf4TnXO+jbRyEZk4RocgpMvWDWnWzo6JONc5H4W
         2EuqN2k1j7/IPM4b23tjbUeB//lnLCvKCTjG+1MQgf1cW+4vfRja/5KWKFMh1gOeUW5w
         K1zyFdJcWpehgv6EExlJ4yBXiW9MglRTumC5uHE1AkSXvv3BNCt7wysCiJnB9ZpDvhTd
         gGsN9r5RaRUqleYt1hK718okA8O9Fzv7a9GVdnftxq+647aHQWKa6Goo4M1OqlrOzaWH
         UH1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ibmirkin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ibmirkin@gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19sor1730977wmk.26.2019.07.03.10.50.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 10:50:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ibmirkin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ibmirkin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=ibmirkin@gmail.com
X-Google-Smtp-Source: APXvYqwbLyqNJUgVnFhv0lbJ8SC5c/0yPQg1tb9jN6EfSosXHl80EFPU2XUiDskY7sdqSQfVQLihXsM+BDW3vYzudVA=
X-Received: by 2002:a1c:7d4e:: with SMTP id y75mr8920034wmc.169.1562176256213;
 Wed, 03 Jul 2019 10:50:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190701062020.19239-1-hch@lst.de> <20190701062020.19239-21-hch@lst.de>
 <a3108540-e431-2513-650e-3bb143f7f161@nvidia.com>
In-Reply-To: <a3108540-e431-2513-650e-3bb143f7f161@nvidia.com>
From: Ilia Mirkin <imirkin@alum.mit.edu>
Date: Wed, 3 Jul 2019 13:50:45 -0400
Message-ID: <CAKb7Uvid7xfWNRxee4YoDSKu5-eizo-0Bqb3amFczEDXmSKLMA@mail.gmail.com>
Subject: Re: [Nouveau] [PATCH 20/22] mm: move hmm_vma_fault to nouveau
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, linux-nvdimm@lists.01.org, 
	Linux PCI <linux-pci@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	dri-devel <dri-devel@lists.freedesktop.org>, linux-mm@kvack.org, 
	nouveau <nouveau@lists.freedesktop.org>, Ira Weiny <ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 3, 2019 at 1:49 PM Ralph Campbell <rcampbell@nvidia.com> wrote:
> On 6/30/19 11:20 PM, Christoph Hellwig wrote:
> > hmm_vma_fault is marked as a legacy API to get rid of, but quite suites
> > the current nouvea flow.  Move it to the only user in preparation for
>
> I didn't quite parse the phrase "quite suites the current nouvea flow."
> s/nouvea/nouveau/

As long as you're fixing typos, suites -> suits.

