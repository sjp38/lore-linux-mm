Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 45861C04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1526020675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:43:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1526020675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB4386B0005; Tue,  7 May 2019 13:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3D0E6B0006; Tue,  7 May 2019 13:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A047E6B0007; Tue,  7 May 2019 13:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50A6D6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:43:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x16so15025438edm.16
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ytCkz687waR4GJ+1u+uF33FVUlWa8FooSFkxCTvV7l0=;
        b=pN4dDSKxftnrDnE5JYnHxLcz0HmkzEk8dETF7DCZPcb0S/bM/WPT1QPJxImpWXU+84
         QUEhZfuk61ptIa9+fDI+xuxiSLT6kQtv0eYFQuaOkXHj9MGcFeCaAEJ2AmG9WWSvYcAw
         63wcXWJQiVyXQ0tEd2hcN5tUr3xyGmKWdHANyS+gFMg0OGbQnuFYZLrfeSznNdEsRHnN
         0RBe9mx7P3y/hd7rxzN6P4Cy30flLPaw045ukgBoMGld/X4Pt3tlS3BuGDfEBmlDwnwr
         CIRNwEG7VWxvXkHCJ5lmUGK+nh/Vk43s7MbDiBwq5ytTLd14K4ODjgOjcFYAHPqkLzYU
         C7mw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXcmcejwIHQMPpADqrqDGBhJdYRK2IcQhCeiswt9E+FVP29LhJE
	pluPVykfatx+q0Y6TGpMabUA/v28K2djf54sY8/VBF7A32G8oTba3vvLPhJBIMIfY9gu3d+T9tj
	3EbmS64pGFsh8a7kKvp17RWIhUehLmgZ9HUJMt9g/HGFZjN62O6Cp5tZSjVm5Ih0=
X-Received: by 2002:a17:906:5c5:: with SMTP id t5mr11854100ejt.274.1557251018906;
        Tue, 07 May 2019 10:43:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywTLkWO26pjv8yLpAEGZFXFbZAGn4A1TbCGdykVUjYERWhX+++Qr6cHeyoCSaCz5EqU0xl
X-Received: by 2002:a17:906:5c5:: with SMTP id t5mr11854051ejt.274.1557251018058;
        Tue, 07 May 2019 10:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557251018; cv=none;
        d=google.com; s=arc-20160816;
        b=yukzslY8kkPXPZOwvrxMfMBFWtmE4saT7+/zonnp0snWG97UNYYyzcrPi8nCB59MKl
         KGnoghlayyFw4bSaBk2iW9gJf642NS7MfCoJJbL2PYy/5U42tA03kwjcOS8elaohhDlE
         0i6EpZrKTTN8uxGPF0qAxeQSzoaWMgRpic9W3677jn9RIR8L3HSc1crilQVOsYZrN2hi
         1IorniLZ487QpYBK22LI8u2OQBgBuWw1MD7iTzjjc3YlV1A1Gd1uJvpG5mN73I4ljrSz
         198a02d2ucPPZ+3HEzSuLDgsPzicBunpPQTvLkptcpgiU+BOH7nZzmvs2YZpksk7YQyD
         fp1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ytCkz687waR4GJ+1u+uF33FVUlWa8FooSFkxCTvV7l0=;
        b=Mjro5XUqB6l93ZsSnizAWUBAJ2EAYdq327SV41fDH3OCa5q1lSlGV/ET9uU7kOZp1S
         l0KE0vBIe/YvrtvBrbjFGZ2I0YkDp8zj+PT/92igolMmFGZTO3I3YNC/X0ghhYGm1Hh4
         gwvIPfAgS52P9iGaDPrMKINNZ543MarD/fLFE1ydYRVB1ScX3NK0cOkQqdk1Grv9cYKe
         Cn1vnfsRV8JYp7nZVJafAVp6PXck4AOVAGyfCD7C1giLYjf7phKjyabLHVY8PY8bEFHs
         coaiwE1F2m9LMNBIavrLzPH0ahOFnst3lOGo0HghXZmyf0hxifSZmv/uxcT/Z8vYyGae
         vDJg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a2si1399021edc.351.2019.05.07.10.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:43:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9CE04AF7C;
	Tue,  7 May 2019 17:43:37 +0000 (UTC)
Date: Tue, 7 May 2019 19:43:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Sasha Levin <sashal@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507174336.GU31017@dhcp22.suse.cz>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm>
 <20190507173224.GS31017@dhcp22.suse.cz>
 <20190507173655.GA1403@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507173655.GA1403@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 07-05-19 10:36:55, Matthew Wilcox wrote:
> On Tue, May 07, 2019 at 07:32:24PM +0200, Michal Hocko wrote:
> > On Tue 07-05-19 13:18:06, Sasha Levin wrote:
> > > Michal, is there a testcase I can plug into kselftests to make sure we
> > > got this right (and don't regress)? We care a lot about memory hotplug
> > > working right.
> > 
> > As said in other email. The memory hotplug tends to work usually. It
> > takes unexpected memory layouts which trigger corner cases. This makes
> > testing really hard.
> 
> Can we do something with qemu?  Is it flexible enough to hotplug memory
> at the right boundaries?

No idea. But I have tried to describe those layouts in the changelog so
if somebody can come up with a way to reproduce them under kvm/qemu I
would really appreciate that.

-- 
Michal Hocko
SUSE Labs

