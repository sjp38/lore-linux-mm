Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57544C04AB6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:06:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0EE20828
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:06:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eBfEUGlK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0EE20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 997D26B000D; Mon,  3 Jun 2019 00:06:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 920B46B000E; Mon,  3 Jun 2019 00:06:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E8E06B0010; Mon,  3 Jun 2019 00:06:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3E06B000D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:06:21 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id z128so14105593itb.2
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:06:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VZoNkUUHxuKOqMH8v2MH2iQcIXpbAzswDO7twwJlvKc=;
        b=ts1aNMVqmkNGBOwHqOfutYfGVakg5Qk0su5UolzfQbDTMechIhiEKUAVmDhz6pGl5E
         ZidsaClbnZx3HQ7U3wEkjxwgjCgorbx92uMRVkK5P77Qu3wbCeJ4jp3evNgV3gNCX4c7
         mJWobWjTuHizbz7JHEg98L5POKfzkA5Uta4gKJcuwO2+przD7yTH8XqQv2dLMs6XTuTd
         Ih4oeq5OTLtNT5wAyhQdbKCLr/7dfMpKUZiTcgJO6HF5V5j2qMbLPy/KapyyVvjop3rt
         M0TvEdq1SrjCDbTO4Qa3Efyp/WJKJzp7z9bWVgYoVkRTz99tGsORRQIk07ewVbaYgUzY
         Di9A==
X-Gm-Message-State: APjAAAVTJ/VB0qOH9bKemCaDg2AdBd4DHn8ieghMX0ppr6NOvFKv6Z4x
	fiH6TmYrER6+6tX4gGQdR25Dfm1HozcO9Jq0lESVQmfpFU9MZUg7qv2YCHghV5nJc0m/krXcWIb
	0rvyNfGunGe8AkIwlt/gheemDdL4217Pg7R1QeQ9c748pb1ORbukY5P04GO4vmC8KHw==
X-Received: by 2002:a05:660c:545:: with SMTP id w5mr1254208itk.114.1559534781122;
        Sun, 02 Jun 2019 21:06:21 -0700 (PDT)
X-Received: by 2002:a05:660c:545:: with SMTP id w5mr1254187itk.114.1559534780617;
        Sun, 02 Jun 2019 21:06:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559534780; cv=none;
        d=google.com; s=arc-20160816;
        b=lFXb9bb0hDznVYG+Gw8rMmps4Gg/BdIF65SRJaxGAE43tUi4ItaApWDqA1LJgaa5pJ
         +Z7FEU0VTcS9LNEU0MJRGm/1S63RVP4MiyD+Lm21pGOqE0XqkHG/bu1oS07hRJSDqCcL
         zoTzeYYyZQy4FwNS+x/JT1qiww70rUg7Gxenb7Dbq/RS8zUXXDIG/f5JTwMREspLT75+
         rJGHobEikrCff21vhDM3nOIsgnsGX9dtfgjx0o1PTVhxhDtMlqcra1tgNB7Vm/sHV7lY
         UOQMy4LB9uActlTHHgFBhz1/uG5VT6yhGg4w3FtLsk3r5guQTOtshYrGYbvJs0e33H1m
         Cm8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VZoNkUUHxuKOqMH8v2MH2iQcIXpbAzswDO7twwJlvKc=;
        b=iDzGzd0FXvd/hxS4l0T0+ATCbQLMaXzAdMxRpmewQHi0IV9agZFx6ZV7PLWbT8GZkb
         urGb9WJX82v9TaWridcvnGSXQqFpHU2TR16HIkRL/Ty3FoQhdMit4lPgWKTpSx2W4Gmx
         OdIXnHt+FSsbBFduIOjcv2Avri0B2cN3GHFfyXp2N4OErflPxgaILNnkxII4S+e5Q+OA
         3Uw2uiAgQ6fT01GVUjtJiaT++ss6lV4fEu80njklR44MwxTY4CEY/iLDm8QhmGGUJHHC
         U8UH//CrXtXEmf/xF0k9thRyAVnUfeeZqYnmfYmpBIamFrXgtzC7xdAmBRpGgPYwrY3C
         hkzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eBfEUGlK;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p134sor755844ita.34.2019.06.02.21.06.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 21:06:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eBfEUGlK;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VZoNkUUHxuKOqMH8v2MH2iQcIXpbAzswDO7twwJlvKc=;
        b=eBfEUGlKHScAMQSLXmTl3+n687q0/LnulNE1jATXybFjerw9z2AUD1P3CHgDM8Ztem
         3UCv5c+jMQLH0zNpKIWIisVM0NjALb1RtUXdtXHN8Q80a7bAKkwjySIKYwpSeSGHHiaj
         pS/w+Ev0YyESB0ILA0nRq132uESIQG70eFYI/Mn7whlXyaw21XKWQhXB+MSGxBoU71bo
         m4Wlwlhs6Q/H5ExEWdseICg3hnyRiTNGp3940lqNX576cyLs2kRQihvj9chEMwZgZWrP
         PzMz5kYN4kqu9QNU8IvOIRtG31+Pc6e8bQs2gwl16PeEEfEKmcNJjFBZ04xThlIghkB3
         vcSQ==
X-Google-Smtp-Source: APXvYqwGBdGiZKLcHhZGWJV3HcFD6Wn6fo+ECEMCQ4j5U5lz0Mxw2HCcEUc2RuGroT1Z9lqrPptDVKl/vohDHgsU+dQ=
X-Received: by 2002:a24:7cd8:: with SMTP id a207mr6519668itd.68.1559534780376;
 Sun, 02 Jun 2019 21:06:20 -0700 (PDT)
MIME-Version: 1.0
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com> <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
 <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com> <d5dde9e8-3628-850e-f2b2-73c08098a094@nvidia.com>
In-Reply-To: <d5dde9e8-3628-850e-f2b2-73c08098a094@nvidia.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 3 Jun 2019 12:06:08 +0800
Message-ID: <CAFgQCTuYBdEvLpUa3-Msu8fJe55zr0_7QbQA3c0LZdgRV+zi_w@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, linux-mm@kvack.org, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 1, 2019 at 1:06 AM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 5/31/19 4:05 AM, Pingfan Liu wrote:
> > On Fri, May 31, 2019 at 7:21 AM John Hubbard <jhubbard@nvidia.com> wrote:
> >> On 5/30/19 2:47 PM, Ira Weiny wrote:
> >>> On Thu, May 30, 2019 at 06:54:04AM +0800, Pingfan Liu wrote:
> >> [...]
> >> Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA,
> >> and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
> >> I've added any off-by-one errors, or worse. :)
> >>
> > Do you mind I send V2 based on your above patch? Anyway, it is a simple bug fix.
> >
>
> Sure, that's why I sent it. :)  Note that Ira also recommended splitting the
> "nr --> nr_pinned" renaming into a separate patch.
>
Thanks for your kind help. I will split out nr_pinned to a separate patch.

Regards,
  Pingfan

