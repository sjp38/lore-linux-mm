Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68E17C31E5D
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:35:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E2CC20679
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 01:35:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E2CC20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C83D58E0005; Mon, 17 Jun 2019 21:35:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0E348E0001; Mon, 17 Jun 2019 21:35:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD5CC8E0005; Mon, 17 Jun 2019 21:35:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 728B68E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:35:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id i33so6855986pld.15
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 18:35:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=awDDTpbSY7XvAks0nmMpiOTb/op+gxmy9nqVdtAt1g8=;
        b=KBFqDAymyM/JYoiXUAxi+B5rHte4TsxX1BHLINfwE17dILKaOtli90udF038JO/0NI
         Nkoke0x6IWxCmk0q4Z1JxOqK4so6//J/kvUQBkB+El17/Kd7J1oe/jwgG3FdewQM89M0
         +P1JlHhKiCwXMJn2Wn5iGG0AZUOOm9bHKxSimAocwN7RTvT6khtG/DemEtHrSLSkQAyC
         CI1s0dUnLdOqEFe3moeTm61rm5qZK5mvqzWycHwXhhL8dQMftTDvH+rZ61LfJbR54n+n
         drxdA/fl5MGuKeXACi2t8v6hE008sFWbbxaaD2vw2bckt1yuHfMaopSWP382zNJTX0j/
         7u6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWgFfPYd9g/rd95VR/KFtScrtdGcVmRRBIcwhTHjnzlSuGOQzLU
	0zP8rbl3kFJQcT+FydBGQytjkI1MESaeLQPslijT6GN3f9Mqwc129ddxtk0Uro9ei0iiB5XAhvb
	PHTWOJ/dunGBgsffNrSM4j5b5D5Gq7ehc7T8LfGOlH58J20dJhlpmHskPAL5Js6us3w==
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr2376330pju.130.1560821751947;
        Mon, 17 Jun 2019 18:35:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjrWv25vzp5OIaB6cT5ZDzDCPpc0N2Sl9sNZzqSk3yPNeTbdfauWityvaVd4c2+Ipx3Kk/
X-Received: by 2002:a17:90a:cb87:: with SMTP id a7mr2376296pju.130.1560821751299;
        Mon, 17 Jun 2019 18:35:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560821751; cv=none;
        d=google.com; s=arc-20160816;
        b=kmDFrLAAVSE66P3hb0Cjwl9q1y0W6VXXvDfqkks03d6Oed9QTM7muneuaWUAmuJBOR
         lLmb6EumhF/V87caVii3wDfeCpkzEp9xEL7xX5DjrXiV+axsuB4ewITZAUD4HefQD0Zs
         RUZF7Fb5CyrdIAhkFn6bkNA8xgKzVRyfwFXJu1y9SoRs6DnCfCjCoPTiJ97UndcP6JmQ
         8eozojov1ame0EFDuwvFq/zAYxaSboG1BT6TvfAdncdjyDpA1nn4tEOq2aa26NUWISCx
         ZDthJgstnEjew8hP0CQZ1SGaeO6IOyoyfslYxFzPAnb4Emdg3RUjPmM+RLmqiW74L6CG
         A7MA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=awDDTpbSY7XvAks0nmMpiOTb/op+gxmy9nqVdtAt1g8=;
        b=0CNBKqfuNPGSe4sARgWA6gjKGJsPmJQWUeQgOLddA3obVF8SmWVawrvLLi6Hc6Oeq+
         fuviaZCYsdE+ltSbzIv/8Dtlt5Ca7CpzPVxYsUKJb5n1wBlBYA0liB/0mCxMrPIm5Bsf
         IG4m665lIjck+fBI9h3dcLU0EqdDsrcRWc0qpw0E5vUTPsN5XG0FYxRIkTy8iJwq13On
         Qchip/DEbGmUXRZwskTftDqzYUhD7GFLroeJeVRnapyLNDm0xt5PHyz0PSI0ozbAoY40
         /h6x7CKnpo3Uzdif/AWXuTXTC1vyxjCmG8cbKP2RFdsoEmPeTQLPErMqbAkJi/U6deEE
         wVNw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b4si3903427pgk.502.2019.06.17.18.35.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 18:35:51 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kai.huang@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kai.huang@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Jun 2019 18:35:50 -0700
X-ExtLoop1: 1
Received: from khuang2-desk.gar.corp.intel.com ([10.255.91.82])
  by fmsmga004.fm.intel.com with ESMTP; 17 Jun 2019 18:35:47 -0700
Message-ID: <1560821746.5187.82.camel@linux.intel.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call
 for MKTME
From: Kai Huang <kai.huang@linux.intel.com>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "Kirill A. Shutemov"
 <kirill.shutemov@linux.intel.com>, Andrew Morton
 <akpm@linux-foundation.org>,  X86 ML <x86@kernel.org>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,  "H. Peter Anvin"
 <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra
 <peterz@infradead.org>, David Howells <dhowells@redhat.com>, Kees Cook
 <keescook@chromium.org>, Jacob Pan <jacob.jun.pan@linux.intel.com>, Alison
 Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, kvm
 list <kvm@vger.kernel.org>,  keyrings@vger.kernel.org, LKML
 <linux-kernel@vger.kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 18 Jun 2019 13:35:46 +1200
In-Reply-To: <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
	 <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
	 <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
	 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com>
	 <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
	 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com>
	 <CALCETrWFXSndmPH0OH4DVVrAyPEeKUUfNwo_9CxO-3xy9awq0g@mail.gmail.com>
	 <1560816342.5187.63.camel@linux.intel.com>
	 <CALCETrVcrPYUUVdgnPZojhJLgEhKv5gNqnT6u2nFVBAZprcs5g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.24.6 (3.24.6-1.fc26) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> > > 
> > > I'm having a hard time imagining that ever working -- wouldn't it blow
> > > up if someone did:
> > > 
> > > fd = open("/dev/anything987");
> > > ptr1 = mmap(fd);
> > > ptr2 = mmap(fd);
> > > sys_encrypt(ptr1);
> > > 
> > > So I think it really has to be:
> > > fd = open("/dev/anything987");
> > > ioctl(fd, ENCRYPT_ME);
> > > mmap(fd);
> > 
> > This requires "/dev/anything987" to support ENCRYPT_ME ioctl, right?
> > 
> > So to support NVDIMM (DAX), we need to add ENCRYPT_ME ioctl to DAX?
> 
> Yes and yes, or we do it with layers -- see below.
> 
> I don't see how we can credibly avoid this.  If we try to do MKTME
> behind the DAX driver's back, aren't we going to end up with cache
> coherence problems?

I am not sure whether I understand correctly but how is cache coherence problem related to putting
MKTME concept to different layers? To make MKTME work with DAX/NVDIMM, I think no matter which layer
MKTME concept resides, eventually we need to put keyID into PTE which maps to NVDIMM, and kernel
needs to manage cache coherence for NVDIMM just like for normal memory showed in this series? 

Thanks,
-Kai

