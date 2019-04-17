Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668BAC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:09:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 189D820675
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:09:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="vQKDMpKZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 189D820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A70AE6B000A; Wed, 17 Apr 2019 13:09:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1FA16B000C; Wed, 17 Apr 2019 13:09:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E6616B000D; Wed, 17 Apr 2019 13:09:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 432016B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:09:24 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id 7so2731441wmj.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:09:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=uI0ONQRkWQ/et5lZr2E50Xppi+adE17aj2er9uc38Ro=;
        b=J9uDkKORe/5J0CmubvChPSg/o9adyHKIMOKobQSrfWYr6ZNiYF8TM96rKxYrZqt7a6
         ixbJsrFjEA6vE/I79lEnLC550ldHtYhiSz8WG/fzYadInI8fKHeYNxOVj8kz+fxOYbkR
         r0l+aQHechY+CkQrns5YXwRKlv41sx8XD1yFEWuyVAJOsswKU+l6gvRSE17brJ61KIYA
         n+pyT6rS15Rb9p023Xaaq/YGM7ENdc0usY3BvI9CT4W6p4jb2AoZYQpLzcTO2afPhwEV
         kzb3jeaOewXYnGRaAxu9+km1tA3/Iwx5QHTqC7LqIIdbNTmyPzrGsQH6pe9SPns2ddq6
         hv7Q==
X-Gm-Message-State: APjAAAXTZyLSXjbDm26Zv6bz2/yvTLHrQ3t98iznRKdV9/LzgzAWUx0l
	vIOpgf1H9j3dR8w3pqsMtx3DSn2ipjAO8CASO13w0WjAXQTSaaShGhxR29S5DnmEb1wPi91WkXi
	pn4Pxyozg4rm53xupmsdgh0bAF1g2UWf6rRHoDVoe1LkAzHQGVX0Nc4hbTH5K1iI=
X-Received: by 2002:a1c:ed12:: with SMTP id l18mr557018wmh.13.1555520963699;
        Wed, 17 Apr 2019 10:09:23 -0700 (PDT)
X-Received: by 2002:a1c:ed12:: with SMTP id l18mr556969wmh.13.1555520962877;
        Wed, 17 Apr 2019 10:09:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555520962; cv=none;
        d=google.com; s=arc-20160816;
        b=IQuc4CDRrdSg+f+UVMqQX6gPpPewnM3gMMigy97z35PAiCNLGDewdrCyertB8EBhXU
         E56bawgbnK0NfQoHHKpKyxQoZ7sttnvJ/XfYQ6Eu8ysUr9PDaic8OZoKEij4YzXFfdMS
         hOt5lye7yMpm1nqf2q4Rl+BZAGxZvE1gIT4+nz1n5qD4Lolu8kDihooxpUWvp0SD+3iz
         V79KXwCHdHbSifRP3TXJGfcoF6yxcS7DeFmEmP0QSsOEloHNIRydV5QmEavQiAlKGvQJ
         gDkrSReYTp0uVYu/ovukdUy0OcRfknK8oBPVwvo6XxZz8WgJ9R4Oac54Lge7D341PJUG
         z7tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=uI0ONQRkWQ/et5lZr2E50Xppi+adE17aj2er9uc38Ro=;
        b=GG6lTmOT9jw8EVxz0cqJ3/mn492JO/jsubYq1swSiJ0+h0AB3yzhlCZ6X4GyisYmVv
         z3cfMhneJNsVy+A+eLNUvQcJOTOBzgPhpBievW1g84F7Irs+0JFezD5ypn7ju9GaveC1
         nG0gUuu/ZsHx4CAye8squ1KfDB1/NNfgYYWlyjEyMG++qauA3DR625yLLnLHbC8n0yld
         d47JQCpo47Bs2i/mMBMnXeYfKR6bLvE9LtmZfPY69pZ2FwnWs/h+zlPld4uCrAYczb0i
         h1dpA9YOljElJnok0U53z4bFhm/+KeQ07yVYKuLlbzrS/mLuVSdZDSrgtn1CaMRHGt5p
         0Xew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vQKDMpKZ;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor202515wrr.0.2019.04.17.10.09.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 10:09:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=vQKDMpKZ;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=uI0ONQRkWQ/et5lZr2E50Xppi+adE17aj2er9uc38Ro=;
        b=vQKDMpKZs+jpCV0AtFjtb+IzANhqz3dew5Sd4gG7ITDXSrt8OYeyxzo5885noBmd/k
         M7Y511AnmRuFNpPrRUcL0fx4VCDHC5HbpoQL157ReLzEY+ATmvDFca5O27ddKmW8+E5U
         SWwgB4fqBVviw9oEx6R3qe3lIZgRJYJXc6M3U+vQZTc8SCcbn5I1BqHYSYodcHy/K7y2
         owHfWC5l9Z1dd3sc9ZHcDGWk/J7z+eM+/y7DQCfdM2D1aY4WwXTWnRz28CERITWBN3RI
         OdgGC3tyQYESSIRNzNO6ctsaUz9bT+jioxPBGx1xhp3GL49llo+vdJv4lTzb9yvWN35X
         0F5A==
X-Google-Smtp-Source: APXvYqwzLRhrBX+v0nCWIiRZo+Ww+BhgVCQVN/Z3qzTyGEskFIzDNjOb+l7u4co7KExCIwSw9l38CA==
X-Received: by 2002:adf:f8d0:: with SMTP id f16mr2701431wrq.198.1555520962630;
        Wed, 17 Apr 2019 10:09:22 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id 67sm2676425wmz.41.2019.04.17.10.09.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 10:09:21 -0700 (PDT)
Date: Wed, 17 Apr 2019 19:09:18 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
	keescook@google.com, konrad.wilk@oracle.com,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
	jcm@redhat.com, boris.ostrovsky@oracle.com,
	iommu@lists.linux-foundation.org, x86@kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-security-module@vger.kernel.org,
	Khalid Aziz <khalid@gonehiking.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190417170918.GA68678@gmail.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Khalid Aziz <khalid.aziz@oracle.com> wrote:

> > I.e. the original motivation of the XPFO patches was to prevent execution 
> > of direct kernel mappings. Is this motivation still present if those 
> > mappings are non-executable?
> > 
> > (Sorry if this has been asked and answered in previous discussions.)
> 
> Hi Ingo,
> 
> That is a good question. Because of the cost of XPFO, we have to be very
> sure we need this protection. The paper from Vasileios, Michalis and
> Angelos - <http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf>,
> does go into how ret2dir attacks can bypass SMAP/SMEP in sections 6.1
> and 6.2.

So it would be nice if you could generally summarize external arguments 
when defending a patchset, instead of me having to dig through a PDF 
which not only causes me to spend time that you probably already spent 
reading that PDF, but I might also interpret it incorrectly. ;-)

The PDF you cited says this:

  "Unfortunately, as shown in Table 1, the W^X prop-erty is not enforced 
   in many platforms, including x86-64.  In our example, the content of 
   user address 0xBEEF000 is also accessible through kernel address 
   0xFFFF87FF9F080000 as plain, executable code."

Is this actually true of modern x86-64 kernels? We've locked down W^X 
protections in general.

I.e. this conclusion:

  "Therefore, by simply overwriting kfptr with 0xFFFF87FF9F080000 and 
   triggering the kernel to dereference it, an attacker can directly 
   execute shell code with kernel privileges."

... appears to be predicated on imperfect W^X protections on the x86-64 
kernel.

Do such holes exist on the latest x86-64 kernel? If yes, is there a 
reason to believe that these W^X holes cannot be fixed, or that any fix 
would be more expensive than XPFO?

Thanks,

	Ingo

