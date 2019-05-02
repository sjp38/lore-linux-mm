Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2A68C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 17:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86E6320652
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 17:44:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="QXat18OM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86E6320652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F8986B0003; Thu,  2 May 2019 13:44:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 182476B0006; Thu,  2 May 2019 13:44:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0720B6B0007; Thu,  2 May 2019 13:44:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id AB57F6B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 13:44:37 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id g36so1420290edg.8
        for <linux-mm@kvack.org>; Thu, 02 May 2019 10:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DaSPhFrdJ9xcb9w7nOB/hv2LmsH6V06QJTIIuydXt8E=;
        b=DKzj96K7QorZPHljVT1VudV59xgDPD9/3wvkXmEiu7SxrjsI0JNHTn/OaSM2YLsR0l
         xMpDnXu79XkvPcxUCRWA5u0V6KKG2uJk5+f6JmIRO5AsLfntDYcf4HYfJjCwmiz3pQk5
         cjTlOU9xsyAJCsq0hPPkrtN01b6uebzXLAHdXUgRwMzNpDK4mNwYfk47ef8YZADVTQrH
         hnaU7lEDDXQ+1+40o17u7JRLhKzlDQxAOm2X/NfY+LHsw0ZS/k/AcZMcAZZST0tTPbn4
         zv/9NmBMwK7hxr2H8ERNZ4567bI+TqBXLBhw4doHTxwyME6IhbXyxAIaES2jlTwDxNVr
         eBLg==
X-Gm-Message-State: APjAAAVPYNX0vF7q5gUhyijsoU0rsnhmreSc0NChjSxADAsnCaSPRXq7
	pLBlyXlfYvp6exho0HCxgUuPTKXYonBcazFILtl1GnKH9CjNdIh04LKBFEvD3ra3nKVvaXycCCo
	znGwLLfJIiF+057/7D9n/VfFKulu2uA7vLa+os9FbTdr3T8JQEjsexptLWihdaZqfSg==
X-Received: by 2002:a17:906:5c0f:: with SMTP id e15mr2469037ejq.151.1556819077147;
        Thu, 02 May 2019 10:44:37 -0700 (PDT)
X-Received: by 2002:a17:906:5c0f:: with SMTP id e15mr2469006ejq.151.1556819076288;
        Thu, 02 May 2019 10:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556819076; cv=none;
        d=google.com; s=arc-20160816;
        b=ExCy5ROSXWWqcHe9z8vVJV1u8HL8pIKZ+bGxrnBMrqAsndA6GHxCXnktxnr4me8cE/
         9+lDGJ2fUZnmHNQIML/LkFi4ujWL9CiuHhZ3TpGgtXfvjD9eqo6zUyhalaNMaSbT3muJ
         W4AhejR4zLxEC/TmUplW42i2qsOkDSKcv9PqottZg0ISUYgEul5LHkfNaDrbSN8SRZIt
         F47I7bacHqOnYnUtbaMyNZFBPxFHWdGP5tX7FIX9IHLJduTSYtRMypLLUhoNu2H61DbE
         o7I8ONmgFvWgmMnA1ymHPuBuKjQpuO8j17skYAZBatZ9EgG2YQWDohYpXVM2S5333zWo
         44kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DaSPhFrdJ9xcb9w7nOB/hv2LmsH6V06QJTIIuydXt8E=;
        b=yhI7JxtwerNsfhj9cfIGSqsF4e7hPSWzkhpNMZl3INNYJLJegWvqhmTYk3RTvc/36B
         g5lomcIpydna6jUT3NFaQUFlv1MuFOB5zpRHFfao5AUVByfJrulKDlyxknUWqR0ngmPI
         Cz67I48jrvVSE0JxIejiOuQ94jy5spf4ovYWI0XAhlf+OhjqTxXEVOaXDSbMWG9nBDrv
         vITl1vd+wl9rE9oeLFo2O8e6UJGngemXOd6tOfuYiPf7GlmpcLAmbevIdcEayawm2GXl
         v1Qn/KAa85DNlHzdwm/mwNQ/OQ3o2VE/+/aa3RDOV79mak7za6AGYnjMPZ8U8VytwxWa
         V1Cg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=QXat18OM;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i7sor4843490ede.8.2019.05.02.10.44.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 10:44:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=QXat18OM;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DaSPhFrdJ9xcb9w7nOB/hv2LmsH6V06QJTIIuydXt8E=;
        b=QXat18OMVYiFj1J2lwckErIND4VxtD7m3nZmTH2CGaJZ+Hw7fVyhiWqHLoK622HkMp
         U9yMIC+ePTVWRGsI21RjnrUuMDsRxTmmjgzsyI3fQ3Qprp0+kiDd7tOOuYY19ZJMOfhl
         l/1rt08HauRtiP2hRqk2NjpJPuP+O+9ngov5zkBNLTuR7qrPf6ExGNub4tU8rsI/TrCn
         n8s8mKEfj18Fxht+PV1z/8GAgInkc9Qc/e9giORQoOAL+mVUg59lDwUFBXIKKGSVU4af
         HayfIxQWJSZlQl6kr16/h15Hk5Reu50LKaP/QJCHnyPavmaX8LyepIFk7cqxBrWSjJxB
         gfgg==
X-Google-Smtp-Source: APXvYqwFjCWrvwlJewJq8jESh0fLZdmcYO3yLeAKyzDonK3UsuXpek6fTdQl1z2LIrzbiszd7BG6f/7lz+swTO1hQHI=
X-Received: by 2002:a50:a951:: with SMTP id m17mr3313780edc.79.1556819075931;
 Thu, 02 May 2019 10:44:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
 <20190501191846.12634-3-pasha.tatashin@soleen.com> <20190502173419.GA3048@sasha-vm>
In-Reply-To: <20190502173419.GA3048@sasha-vm>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 13:44:24 -0400
Message-ID: <CA+CK2bA-jVEXvF-gi1N=8jD-+MPsqtn0aod=iBNJ0TrgiqqBSg@mail.gmail.com>
Subject: Re: [v4 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Sasha Levin <sashal@kernel.org>
Cc: James Morris <jmorris@namei.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, 
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

> >device-dax/kmem driver. So, operations should look like this:
> >
> >echo offline > echo offline > /sys/devices/system/memory/memoryN/state

>
> This looks wrong :)
>

Indeed, I  will fix patch log in the next version.

Thank you,
Pasha

