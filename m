Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 041EDC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:18:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B00D620830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:18:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="ZO0IGp0O"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B00D620830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 549366B0272; Mon,  6 May 2019 14:18:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D3C86B0273; Mon,  6 May 2019 14:18:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 39B356B0274; Mon,  6 May 2019 14:18:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEC426B0272
	for <linux-mm@kvack.org>; Mon,  6 May 2019 14:18:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x16so12746270edm.16
        for <linux-mm@kvack.org>; Mon, 06 May 2019 11:18:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HayB7sQuY+v6EOo4zgx5AzoxFFOqeB4N5OR8XF6r5Uc=;
        b=T+lZRlsd3Fx2m0zBYtwrq8qlFuuKn2UJPHbQlU+kRv/AtresETEGAuHAbFbQcNKfaf
         7z6hGeMA4hkHibEz3UTn5rB4RIasNq+X0pvPIeeOzL6ZwpBGiseoqKz0ey+nT9LfM94r
         6sbg0UbbL54UUrjsHN4e6xmjt6/bzA2SUMsgkENAmJbUj5HY4b1V+xt38rqemWDyi4XG
         kZVliEA8/Ybc7suC7gVEdU/GPckUeZxnpHqDy7hW4I6h1n0bMJgOFzNX7hlO83oUI7mU
         SbKq5su6nlw2KjLdyaoYEYO8r4Xpsh7UsOD40Y55npjBa0ggqKAgppkETIDYWWvuQoqY
         qnIg==
X-Gm-Message-State: APjAAAWB4CnNJeKXHxhwnGFM6TpCGqgEducHm/Nomov3XOOgCn3U7OC4
	jO2mbDZ7gOyyBQ1CElM2EMiVffm3I0WyiAgFo5e8Fb2aYm+/pNSVFWA+dcwt0NZQlAJ9AYABiJG
	IKJYVkVf4pOUZpJ/boqx2DImJ9am/aTbEn0CZbOfO9gd4S/E/o9c24XO1xVvDCQvsZA==
X-Received: by 2002:a05:6402:1256:: with SMTP id l22mr28194588edw.22.1557166712420;
        Mon, 06 May 2019 11:18:32 -0700 (PDT)
X-Received: by 2002:a05:6402:1256:: with SMTP id l22mr28194426edw.22.1557166711726;
        Mon, 06 May 2019 11:18:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557166711; cv=none;
        d=google.com; s=arc-20160816;
        b=ECuTJy4vlaN+2bAhBIAxzhJAmNzQz4rRI4hx4t/5yDaosOwd6JVAEzt6y6Z3Kb00kl
         FMDxQlHo4xWzrRTvLeEDE53kKHqDRYZooLEUceOVrLAc5hKbEcVIZl1YhXCQ57MsccQ8
         xKd+UMIFjkNfG9gHFyHyezqMjkfjuJy2IMtER/LxtVpkZWCEo0JGNcpVRDqMZ9eq+XU/
         i371ZrekrtRZJfU13moe4kXqlD8FG5T12Gtgp38mdK54Tlq6XezjjyYFij/b9zwYP90i
         PtagUS6+lcow3OnjfQMRjxmaQ0I+aAgS4DXxdMP8w1w6iipWQzcioi8ucuQNxrqR/9UW
         GaQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HayB7sQuY+v6EOo4zgx5AzoxFFOqeB4N5OR8XF6r5Uc=;
        b=gRsBZj7/sSSyjl/JQfgPxeoaBWD07jy7CE9ImUZx7F0LeCRXzPLQcYjrvgk0jfsFUF
         iQF9FYX8XGhMvBrEDZKP+qISoLVvKFz5lkKp7uNKc756CXOvTqp7xUOrKIpVi4fjcLda
         lvByqpE7eWe0hx4eOVjffLp0pKewFQ+Pt57gqm04/TpU5F4L2iPBWEn/7JEtEYzxqy7K
         pRVXWrk9SAu7QwMv+9Wvnyz9BOHN5NHgF/sJwaAJe6j0LMVhLkq5tNHVM4zOY5D5msuN
         HN7uQaESt539AVgEtg52wevaPPyYA6PcfTn/3Sjls9wdA0sx3UuC+tXQtDQ+kzdJMGau
         iHRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ZO0IGp0O;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z1sor1722224ejg.6.2019.05.06.11.18.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 11:18:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=ZO0IGp0O;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HayB7sQuY+v6EOo4zgx5AzoxFFOqeB4N5OR8XF6r5Uc=;
        b=ZO0IGp0OlSdXA+IWacCTnCe28YL0KDN5WLR0iOy2RQwLUXZVopK4KJfjY+7Q/z9X6s
         SjuXLmGb7eUbUPJHlvDgd+B3s08Ybui1oQ9ioaIhBcDsAz6stlJCXGs9JZSL5YKh43lu
         Nwu+fb1XhtGFgnaFbhK852KIcA+Hirr1L1Uu2CPoxojTIdKceAWJbAZ7TBO6HNLfSXLH
         IqZeQ9Y3ShvtCySSy+qfuIwbk91roy5qHtFp8zbKkADnaXx4F2yKU1KCdSog3LdNJZ0V
         /oPFwD9Z4Ilb/jEbM5g4Mp2y3Hs7tChLQ697C0ly3r+YHVZPXTFzV9DXetIRIhfLCKSy
         AKNA==
X-Google-Smtp-Source: APXvYqwHXBTigtDuKWMtEhHCcYHo0Ym7KuPj7imSV/QN0gZyF9gZvmtmygbEq5LNv1SmyCzL2+klGlSO4LgamYmNN1E=
X-Received: by 2002:a17:906:5c0f:: with SMTP id e15mr20354898ejq.151.1557166711352;
 Mon, 06 May 2019 11:18:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
 <20190502184337.20538-3-pasha.tatashin@soleen.com> <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
 <CAPcyv4greisKBSorzQWebcVOf2AqUH6DwbvNKMW0MQ5bCwYZrw@mail.gmail.com> <cf793443-c14a-a1e0-856e-15e416c7f874@intel.com>
In-Reply-To: <cf793443-c14a-a1e0-856e-15e416c7f874@intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Mon, 6 May 2019 14:18:20 -0400
Message-ID: <CA+CK2bAfjXCtRRV2DWy8huCvJ-y0L5cMvOh+9CS40WZfhx-aeg@mail.gmail.com>
Subject: Re: [v5 2/3] mm/hotplug: make remove_memory() interface useable
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 2:04 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 5/6/19 11:01 AM, Dan Williams wrote:
> >>> +void __remove_memory(int nid, u64 start, u64 size)
> >>>  {
> >>> +
> >>> +     /*
> >>> +      * trigger BUG() is some memory is not offlined prior to calling this
> >>> +      * function
> >>> +      */
> >>> +     if (try_remove_memory(nid, start, size))
> >>> +             BUG();
> >>> +}
> >> Could we call this remove_offline_memory()?  That way, it makes _some_
> >> sense why we would BUG() if the memory isn't offline.
> > Please WARN() instead of BUG() because failing to remove memory should
> > not be system fatal.
>
> That is my preference as well.  But, the existing code BUG()s, so I'm
> OK-ish with this staying for the moment until we have a better handle on
> what all the callers do if this fails.

Yes, this is the reason why I BUG() here. The current code does this,
and I was not sure what would happen if we simply continue executing.
Of course, I would prefer to return failure, so the callers can act
appropriately, but let's make one thing at a time, this should not be
part of this series.

Thank you,
Pasha

