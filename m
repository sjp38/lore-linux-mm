Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59BFFC282DD
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 03:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2716217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 03:25:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="AJYXOTYa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2716217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 41A466B0003; Thu, 18 Apr 2019 23:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EF306B0006; Thu, 18 Apr 2019 23:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 306AD6B0007; Thu, 18 Apr 2019 23:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id F147F6B0003
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 23:25:36 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id f103so2131867otf.14
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 20:25:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=M3KZlmbTuZ2H5T1ldOvJ/lTcJF1EunhRYO6gI9bp16A=;
        b=UI0X8CSt07tNZBK1FZqBKdHsPCcqt+mmY1TRumcKgI/DYaTY65fw5zoCXGN558NdTN
         U6LxERicatv7I+yElM0wszStotnasILetW69EoAvSrjUZuClQBgwriZnjFVAP2AKkzWh
         4berWKxAAWPHQWdhjKWuLq2yPxVa8himmcoDPbFwpaypWf3jhq5QaL7wh1Nt+qC8EGVm
         rsRw0jjAYXZPZIkMheJ03yhinwyprM91aHZVVibrmkw7hW1dZDZZL1YJjn8sHuE8LSJ7
         YPc8H4OzVD/PwnJXuyruRJQDCUVa2i8uFLlxGfrWJOCIs1l9w1DCljw94i08CFaoO22f
         h74A==
X-Gm-Message-State: APjAAAWurbcs2t1moRsEYLIseswwMVEPLbRR9T83HOfX3psuwoPpgvBv
	ul4rcuQKkUViq8AtH14XxGpuUJ3PogiFSKgMZc9VbOFCu95zPibj397pAzkUBZ57c5oS+775dt0
	x0/J2VQlijMGvouQairSfFzArMzOMlWNsIqHfcENIaTU8cY6rsgIpSYL/tjV2pq8yFQ==
X-Received: by 2002:a9d:6292:: with SMTP id x18mr858381otk.224.1555644336365;
        Thu, 18 Apr 2019 20:25:36 -0700 (PDT)
X-Received: by 2002:a9d:6292:: with SMTP id x18mr858342otk.224.1555644335245;
        Thu, 18 Apr 2019 20:25:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555644335; cv=none;
        d=google.com; s=arc-20160816;
        b=il8yAZ5XYLTn/2t0PwGz4qyab+1VriuoZHCSSeyKYK6e4N8fLNCk0tIPzn++x15Ru2
         hteQrQkDcYlmxSGEhmKdsGMdvaMOPBnJBzkDaaEZp4tDOAkc3Z1ob8owyE3ZPEcLNB66
         pLQ/jCdHn3jDOouHRZvsGpldSJxD4P+FKoSaDu/VoZb2cBxSsojPAU3v3uLguH3Tah2P
         4Wtrh/dffv+Vyxrtho5HkX8lztdkmkNP1DfZ3mLU1pEX9an486gjmjUrHhaWs132akFg
         nBZl45xtPH/jcJ2dyYVDlXqQ+uMhhJuUnzcMvEPFKWSylz5uB2wckJEz21/PHKr7xVLt
         3Hgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=M3KZlmbTuZ2H5T1ldOvJ/lTcJF1EunhRYO6gI9bp16A=;
        b=qtg6e7nenEVZ89avltX2Vk4oeiBJZEtrJbkbVeLRQEcWuBb9qWAbolIhYeOIAx/ak7
         QRjoyLKppc6sTEo5IG3HH9TPP7CZsr5Uj2uNIlkMCZ21dvVulZkICnU8bjEAq0VNJx7K
         yVRX7/Fnfu1982jloua7eJkjk4uiClbxV5KDp6dzHoUNDU7rnZ/hJ5soouaItxVv/ugh
         SmLVJdA9fXtbTZEANV9WZNB7dvPdv9yfa29b+uiy5HK4oaFe7TRRvWM5EnIB6hy6q0S4
         Yf9+4E+W0fTW41q+3K/UCyj7S2I6UoMIKcIblA649+Kx1gMncSJp04JPBkbXWbPsEvAV
         EJkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=AJYXOTYa;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c78sor1754999oig.18.2019.04.18.20.25.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 20:25:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=AJYXOTYa;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=M3KZlmbTuZ2H5T1ldOvJ/lTcJF1EunhRYO6gI9bp16A=;
        b=AJYXOTYal8a2RJDZxJcIFEijx9f6mEXGoR2tvf87cLkTecJtJ9YSBPnmpvUr4hok50
         cOQr9jW3d8KRIyb+1UWV7nyqpA1jlQVBa8IQI/Mq1U8oICkWET/LYgNdqqIGX5OyOamG
         +iLu0IlSHZF84ih+uZdtIqpI4lRnXwEfZH4vfm6YZsQ7SROSE6X/D8pmo+m/2WmZNKCa
         FTOMq7Kcdcu8EA9JfZ3lbs1IdfIi/zIOknFoud1nDCQhyTPiA08KHifPPr53WK9uqR45
         MbZe/7R714qEPt1svrbQqFNxhAm2ALVqpOp1yDMoV+XcdJUIXfyBQeXUF+fKft4Gk/Ho
         IeRw==
X-Google-Smtp-Source: APXvYqzZF3vp7DVt9JqqtH0Z9V1KA9PGDB7qSCTpqgGKNLlAzHxWdi2y+8hfsB3Ix4eXJHqq+3zDLC3S85uNsv5YmY4=
X-Received: by 2002:aca:aa57:: with SMTP id t84mr700347oie.149.1555644334421;
 Thu, 18 Apr 2019 20:25:34 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
 <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
 <CAPcyv4iW=xhhUQbg0bt=xCgVaR_jUvATeLxSoCfvzG5gTEAX6A@mail.gmail.com> <x49lg07eb3d.fsf@segfault.boston.devel.redhat.com>
In-Reply-To: <x49lg07eb3d.fsf@segfault.boston.devel.redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 18 Apr 2019 20:25:22 -0700
Message-ID: <CAPcyv4jZwRfL5st3_MKwtTyuX8Rb+dYq6vpqwaEpp+BmZTgrYQ@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Hildenbrand <david@redhat.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, osalvador@suse.de
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 5:45 AM Jeff Moyer <jmoyer@redhat.com> wrote:
[..]
> >> > v6 and we're not showing any review activity.  Who would be suitable
> >> > people to help out here?
> >>
> >> There was quite a bit of review of the cover letter from Michal and
> >> David, but you're right the details not so much as of yet. I'd like to
> >> call out other people where I can reciprocate with some review of my
> >> own. Oscar's altmap work looks like a good candidate for that.
> >
> > I'm also hoping Jeff can give a tested-by for the customer scenarios
> > that fall over with the current implementation.
>
> Sure.  I'll also have a look over the patches.

Andrew, heads up it looks like there is a memory corruption bug in
these patches as I've gotten a few reported of "bad page state" at
boot. Please drop until I can track down the failure.

