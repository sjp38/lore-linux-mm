Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41BA9C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 09:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08195207E0
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 09:04:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08195207E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 825556B0273; Tue,  2 Apr 2019 05:04:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D4C96B0274; Tue,  2 Apr 2019 05:04:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69C7C6B0275; Tue,  2 Apr 2019 05:04:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 34CF46B0273
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 05:04:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s27so5550653eda.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 02:04:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=t3S8n/Fw7VDzOQRxPDvSPf7/nn3stadU2Ol6w5kvdD0=;
        b=AlNU7GnMyoC7NpNOonuOLjw0Wgt6tZ4n4EIMSEVX90f7sXiF8UbtTPxtJooxqy7Skc
         KlsbIrkMP3F5jZbFlIBbaRUvanS4lsnorl5Cmt3cSirgPQVM/5/coOzjdwJ01kSHr4Wf
         h2cUobZCONoUfXM37umfLf+ByAYi3I+cdbgwn5YxypJXG0W5G3zSfmXf9IPfd/ISe12K
         uFTIawEzG5BGVH/uO2ucV1hOGxW5+NrE77It/7Mbx1wNz5VB7PunRtiKNFTSG6KxlCJT
         1uA9djmXJ0uYg3135rb9i8DteCNY9fDYmcfAlCnRNED6ij/E7ZQOTxVh2RyKZ1j5cskD
         uc7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
X-Gm-Message-State: APjAAAULW+739sah4hCMroyZLtu3j6XRLIluhcTNOSjTbRRlC+4J0nww
	a6IZIt4vcyxY/Acl8+yV/JCbVTIxVYOij6qmn1smUnFrHPW/lUGYiC13SdKRXi4pbnuSGam2ye+
	kSqqI5Fk0KTg/TDzhmADbPJteZ2xaxXr+xz1sGKCFa/nhUXdkF5fNIkRNBM2hnHXOsg==
X-Received: by 2002:aa7:c69a:: with SMTP id n26mr44933900edq.113.1554195872722;
        Tue, 02 Apr 2019 02:04:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ0q1x2eBl5HbAE2oYCltV0ITkNehTbOfFjeQPIdpJEMf+DusriHRjLzn6J7tgwm7GdRAA
X-Received: by 2002:aa7:c69a:: with SMTP id n26mr44933855edq.113.1554195871918;
        Tue, 02 Apr 2019 02:04:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554195871; cv=none;
        d=google.com; s=arc-20160816;
        b=sqzg/EsfbG5Wed/JiwUwcYPFC5fo2xPryzc4UrdWhM86uisFjqHW5GH1eUlTp3MczK
         rTEHl5PoWAmjz6hDzA7aduecHTpmCdBi1tZFx05AN/+mqZ/Bgdux5UhGxODH2cXwgIZH
         8tr2s++YifTSxD+6zwTX+BQBI3U1ecm6BqPXKYuyYU+FmLr7/O6s+Nva3jyC+Kv+U2oC
         HSMyHRJM/mOZm77SxJ9abCf1i3c7+39SrbzdA4rhRuD+dPqzJNAivWrSmJLfVl1htm23
         zpB33ild/AHDHjUgqajfKezZhICQ3UN7b1R9GQkI/VYJjXbZCpb3KxQ7PmGCfFVF1veb
         ASWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=t3S8n/Fw7VDzOQRxPDvSPf7/nn3stadU2Ol6w5kvdD0=;
        b=SVZln19Z5gmJXDvCjayJUojGRtnr1WLNALeP7yaljda2hr9uHppa+I2ErXkU+M/jEv
         odtQGFRpKctPi88wlyq4oPmOTpIJTxIdmMBdzqQ0tnXGVQB4yKsjsatOK9rYZAiS96pp
         yEuQT3VkvoQ3eKLgI/bwKx2q4ggjLAfjLAMTMsQIYrEFmwwx4e3h2eg81TxdHj2FhXIu
         NJqkRcUuA1j2wT9qn7U48YIvPsSbEtdHGpUei+ldrnjeSTgW6sQFAtWvZv30H11ubZKD
         ED+pb2HypxG5YNcK/vdOBh9k28c3P2Dg8NvGKFTRVxJ5NUFWwDE+DdlTqxYAF2Wd8rI3
         xXKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j2si2351159ejt.260.2019.04.02.02.04.31
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 02:04:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of will.deacon@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=will.deacon@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D190280D;
	Tue,  2 Apr 2019 02:04:30 -0700 (PDT)
Received: from fuggles.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BC4B83F690;
	Tue,  2 Apr 2019 02:04:28 -0700 (PDT)
Date: Tue, 2 Apr 2019 10:03:49 +0100
From: Will Deacon <will.deacon@arm.com>
To: Yu Zhao <yuzhao@google.com>
Cc: mark.rutland@arm.com, julien.thierry@arm.com, suzuki.poulose@arm.com,
	marc.zyngier@arm.com, catalin.marinas@arm.com,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	christoffer.dall@arm.com, linux-mm@kvack.org, james.morse@arm.com,
	kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH V2] KVM: ARM: Remove pgtable page standard functions from
 stage-2 page tables
Message-ID: <20190402090349.GA25936@fuggles.cambridge.arm.com>
References: <3be0b7e0-2ef8-babb-88c9-d229e0fdd220@arm.com>
 <1552397145-10665-1-git-send-email-anshuman.khandual@arm.com>
 <20190401161638.GB22092@fuggles.cambridge.arm.com>
 <20190401183425.GA106130@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190401183425.GA106130@google.com>
User-Agent: Mutt/1.11.1+86 (6f28e57d73f2) ()
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000006, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 12:34:25PM -0600, Yu Zhao wrote:
> On Mon, Apr 01, 2019 at 05:16:38PM +0100, Will Deacon wrote:
> > [+KVM/ARM folks, since I can't take this without an Ack in place from them]
> > 
> > My understanding is that this patch is intended to replace patch 3/4 in
> > this series:
> > 
> > http://lists.infradead.org/pipermail/linux-arm-kernel/2019-March/638083.html
> 
> Yes, and sorry for the confusion. I could send an updated series once
> this patch is merged. Thanks.

That's alright, I think I'm on top of it (but I'll ask you to check whatever
I end up merging). Just wanted to make it easy for the kvm folks to dive in
with no context!

Will

