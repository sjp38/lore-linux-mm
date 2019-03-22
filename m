Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1D03C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DB8E21900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="pKk8vaqm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DB8E21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F36286B0006; Fri, 22 Mar 2019 18:15:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE4836B0007; Fri, 22 Mar 2019 18:15:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE4F6B0008; Fri, 22 Mar 2019 18:15:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B842F6B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:15:22 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id w11so2881220iom.20
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:15:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=NxtbMONzoE1s3tzmii8qj/NkqDi2oTH0iJ5EH+lwhzs=;
        b=pU7DtFer36blEhO5Pfffh8U98O37I/p2oxSyDP8CY/GlqDZGM1LikjzQebkxhrjx2D
         VA4ITusxVg7acnOvC9xIlN3LwuGMHJwCSuDS3DWIYOgINBmxLKH4EDV5buDlZkIg1IcW
         XkG68RnvFR/m71kdSWVc8HKqYPhBtHRhk6blkDH+/68da2muMT5XQkCdWbpvfG3ceMGG
         W0AVB/vr3mlUjz3uCctP/BjryN0MdGX2xOoIHlicC3EdGyH4WO9oK6Nm9C5EXXVWuNXz
         pRXDi4mbQET6QegWauj3zEhCA2n7W5IoN2I/NnIdkGlb1ntdzb4lspxahOWyEjE6LfGv
         Osfg==
X-Gm-Message-State: APjAAAUGW7jzsa/X/jSTy59UjRfE6aQ3keWjrq/Nx6YJBnbBaGG4Worf
	s1g9RA4YSVFuqUH+wINRDnfNQQMIZT23bGjNctpUnI/QE4T4vQCkotSWJb8X4FzHq8Q2UMS+aTj
	riJPIhuF1bhL/4zN2QLzWN/fwpGV7eX9tSoVWHyp8qVa/710QZcMPdVk4bDoGVjA=
X-Received: by 2002:a24:5208:: with SMTP id d8mr85119itb.137.1553292922534;
        Fri, 22 Mar 2019 15:15:22 -0700 (PDT)
X-Received: by 2002:a24:5208:: with SMTP id d8mr85072itb.137.1553292921998;
        Fri, 22 Mar 2019 15:15:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553292921; cv=none;
        d=google.com; s=arc-20160816;
        b=uE+yV3Ai6gc6B0AMGjHX+rNAD47XPcZYbmnKMHpeLIPwV26dvN5WhjNb7rm8CEDa25
         XfixJ/A1v/ja+G4trwUcAv6bZJ6ikxfSvKorYNgPxa4VFhBf+2nMTxL2/0K/GDU7Ih1p
         tVexcwQuXRcg4IDVMrVRX0aP69JEAgZm+6rgoeapxBdWqktbmGUTVHEoufY2q9e/0q4n
         vD+w5GtoQzlRC9nr7Hw0OF0mfxdv72ILzWxr6wpokoX69OZN52WikPp38wlRG8wtrQ6T
         5NV+w4Z4c/wtnqVEWwH++Ru1QE3qxrnvTuS6sw2Bq7nstWglGv+NhTFm8JieRsRGoTxg
         Yn7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NxtbMONzoE1s3tzmii8qj/NkqDi2oTH0iJ5EH+lwhzs=;
        b=OCeSM44Amqdjj799FJXBDHut1XeZpUfd/1n9LWGILWdAXFEz7PoVL+psa+AOtbO3ko
         Nn+rCVc8YMQykzAOi8J8b3frvc4g+bYjr6gLPwb3+8ePHSGWqyL4FVWgpYn3MqWEX0Vq
         5sQozEyULtDY1RvSzSv1CecOrEMHlJzHduqe7AUWRY7FbW7xuXEdpUorVBHN5sE8ggXt
         mqfOmrSw0/hWF1D/cSl98+m75zx1y4Sazg+4v+rOqS4dkOHXwRjeTSiiYzUiVSVginID
         2K3yp3Uwefx9wib4dXfXGoKc4YRjpTsgumim+veaZtr8+d/XLgSy1C8EkRZwAkRq8/Yv
         3wGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pKk8vaqm;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a184sor16852947itc.31.2019.03.22.15.15.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:15:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=pKk8vaqm;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=NxtbMONzoE1s3tzmii8qj/NkqDi2oTH0iJ5EH+lwhzs=;
        b=pKk8vaqmEOWE7wmsQsAlpVqHxGSGlzdO18CvseUDa6Gqg3ToKg6HC+d6WIlSijUcfE
         eqZis0vwDECjehXasWtExjdgpfVBq/hrPtiOoQQSKzK3TjOl/nTT+9YmHvwUR+PM7IA4
         SOb/KicPs2Y3XnvO+puWR7yKpWhSgZFJhnJ6r4/irdDupSuupBFv6JOsvwLkAcOJVCvc
         /c6q0yBJIunL/GfMeaZCvO2zo7Le+40UBax9xxx16S5aZ0WDQh3P5CgePOvXOOBPFbgz
         HBnYydx8J6DIC1a5uoC8HcWUFBhtiH/ArOQmUpRQZYjiW5VzQldKh5YBRfOuJhQ/9xvp
         6L0g==
X-Google-Smtp-Source: APXvYqziYcin9TkCNIVMFnILirct4rYKpjMxOpZQfFl5u+ozFqvpcOi02iZydMgVTL758Vu3P43GvK0tXOYXgqNrS/o=
X-Received: by 2002:a24:298b:: with SMTP id p133mr3587931itp.43.1553292921652;
 Fri, 22 Mar 2019 15:15:21 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-7-ira.weiny@intel.com>
In-Reply-To: <20190317183438.2057-7-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Mar 2019 15:15:10 -0700
Message-ID: <CAA9_cmdDxh1ZYn1fO+ED1crzDMCPWk0fLjNPfxkFKUb5kNHgxA@mail.gmail.com>
Subject: Re: [RESEND 6/7] IB/qib: Use the new FOLL_LONGTERM flag to get_user_pages_fast()
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> Use the new FOLL_LONGTERM to get_user_pages_fast() to protect against
> FS DAX pages being mapped.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>

Looks good modulo potential  __get_user_pages_fast() suggestion.

