Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4CA9C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:37:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2965C204FD
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 20:37:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="QZVO0YSd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2965C204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A4F7E6B0003; Thu,  2 May 2019 16:37:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D80F6B0005; Thu,  2 May 2019 16:37:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F0216B0007; Thu,  2 May 2019 16:37:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB9F6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 16:37:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z5so1654433edz.3
        for <linux-mm@kvack.org>; Thu, 02 May 2019 13:37:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Gz5D/2IZBhXJoQXag9Fc8P8nFKA7bPD957oNqAWGLnI=;
        b=G0aKG4S6IiDYA1tp2gxGr0CuRMF7F2xxNQIhmrYlbpGNvFyJ2Y2JFptaJ4iM0YjvhH
         1xbmYtUXrsVKglAbWKPO5tZRZ28gp7lIHxOl4iPvKzZ8c07P353nJ9zRGa2EWMJI9s7V
         IAoKSYuiCawOFu0fM51brpEjrSHAgeqPHXtL7EpSPyLq+vrPxbn8N58+QgzmwsRAtBxh
         D8Ljz/BxOWJJnKYpY5LfcBybv+2QGERS+g+raQ7t1A5huyriUJ1KHRitIa32UppaJprI
         PDFrKZLSx43AInJL6jfo3AhpvDgVvNDEIrT8qZoMeLbeKCmPFKGeiHiDcId4eZfC0L0Z
         j2KQ==
X-Gm-Message-State: APjAAAW5zQpgvm0EAVxPC8zAA6IEQ9NCcZ6BQn4Nvvh0X0V34mXiNgDX
	Syh/S+f9T3CP22hIWIpqGRT96lxeg8SbZ84v9tSLq+GxpkahSOUrcvtTDpaPsTmmoUz63gSsSgV
	6NBicx8IRfXrhYstDtruXw0tehUTBV7QVVE5FYz3KCgsVMi07sZEgf3e4TNAEMKICpA==
X-Received: by 2002:a50:a305:: with SMTP id 5mr3835722edn.164.1556829442865;
        Thu, 02 May 2019 13:37:22 -0700 (PDT)
X-Received: by 2002:a50:a305:: with SMTP id 5mr3835665edn.164.1556829442027;
        Thu, 02 May 2019 13:37:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556829442; cv=none;
        d=google.com; s=arc-20160816;
        b=Y9RpC+Ajzn8aQ6/39SzgocBLx7uiozd54Cpk2rgvv0JUKkofSrWG+X8q/YVcT0xMm5
         6Tidq9PLayWTkNSf2cZhk/DsXxfzXZiDI6TttiMR0yY4WFzs7j9w9r06CaLEWjiPdcJq
         R/iEEAMkWEU8DRx77/ChycnutqXTSqgmsBjCMBUC49ukH0wK1CPNwgujrzeEz+U/IfrY
         Z49WmH4AvRmX7Pv33EoCYAlPGGjwK00nCqYipi7NKE40e3sF50Oa868G7RGU0K6dtINF
         ITy8T5LbDJCkJEQMx/G2ZaRx8NsCBvwJfdkxU74cGIsNupohs7W/VLvVRdweLbfEFByy
         KhbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Gz5D/2IZBhXJoQXag9Fc8P8nFKA7bPD957oNqAWGLnI=;
        b=FCd5eW6RVeJl0TVHSQpOmnTcRTMSHG5nrUriSc8W2fONYqvwZaS/Wp9XicvS/JuxgO
         f2vgP/+Kasp/bqRTsvFHn2X9hBeErgsEo4RXphVQlbVp6U6MPH9tCz/6FhTf4RdK/ums
         4YieEwcojLPOHSsje3pxgjc/USkMPyImbtAEU2z7VIfT7lQuLjH7zCBESxTSnn2pF2ic
         903Egd45etX3XZvMT2zCTc6ezyV0SK8V52ADYmjABAlhw4FxKtoLrXFuOGH+/JxKTRZG
         2Kaub/DoznNNXq+Q42idSe0/sQdisXz6wfoauwJpnhsMNBbCdegVufFASXEItaK98ozR
         cqFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=QZVO0YSd;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e51sor47229ede.15.2019.05.02.13.37.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 13:37:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=QZVO0YSd;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Gz5D/2IZBhXJoQXag9Fc8P8nFKA7bPD957oNqAWGLnI=;
        b=QZVO0YSdzfzmNkr8hsoJiK5rKpblzW2amWDf3n87XB8fhXoSn/0aPPhTGprY8sH432
         Z9X7TBXWCAenJ7hQ8icWnharyhUwgZ07H/pYlQ9TRdzVVXoWeYT8vhGH/fpmW48/UU1w
         fo/fFr2FjArozB9eIWYNn6qqw7kSEo5ExaZZTLUjW52JRwMc/0f2sCATYTBnkzex1s1m
         wNvW5yhMCcea5C0W1TxWewa5XQh2j91YM+6UmdwPmCFYonn26TtLe9INPuxY0Ofo/Wyb
         +B/lwdxoIwUp9M3BAOpE1x2CBVcQRXItCPqMojFeHF6BT1OS8dSHKenLwEW1jW/5Y8XA
         NsMg==
X-Google-Smtp-Source: APXvYqxm66I1vthEPriE60HFHxcqTEq91Ksjm4zQsKZ0Wv4hwE8siQJ3nxYgBpV3fsWjIk682fpK9nZBMPnTkHm0aS0=
X-Received: by 2002:a50:a951:: with SMTP id m17mr3830583edc.79.1556829441732;
 Thu, 02 May 2019 13:37:21 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 16:37:11 -0400
Message-ID: <CA+CK2bCq1KvdqZA6=_=F4CAem0aPCLYWFvrMavjm5F1+h7MA+A@mail.gmail.com>
Subject: Re: [PATCH v6 07/12] mm: Kill is_dev_zone() helper
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	David Hildenbrand <david@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 2:53 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> Given there are no more usages of is_dev_zone() outside of 'ifdef
> CONFIG_ZONE_DEVICE' protection, kill off the compilation helper.
>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

