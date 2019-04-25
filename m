Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C784AC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:36:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 707D3206C0
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 13:36:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Gg0uxuaD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 707D3206C0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 07ECB6B000C; Thu, 25 Apr 2019 09:36:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 054386B0010; Thu, 25 Apr 2019 09:36:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E85556B0266; Thu, 25 Apr 2019 09:36:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB8F96B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 09:36:41 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id z125so6242778itf.4
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 06:36:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cilSacm49Yfv3yMpgdaQhWv20ykDrXiN3MsGcQ6O+1Q=;
        b=S5C9IVJJjRHQa3F2GTP5diDoOim3VZOs5hbC2CgEHq6UMaEayAnHpgpzOQZuN8Yh7v
         iRSI3O+3auvnqXbj0OPUVsAauFWPNwtF2VmAfR57ZPJ08dUSJh/w90anrwjFHPU3Brrz
         1o1VAyPjqGk+5bzHYayFVZpQqnOD10kXNb/yKQZEEF7Q1zUnkhtgLkSj4Q9zakMoYWBQ
         amfDdwsllcO56uvqxV8kkJwxuelti30mCRC3US9HCmlHIc+VMDLexcT3pZTmJeQhPbFp
         +ojJETHtjitIpsz8IjjBEd05Re6HQM+YjfOfKL5e7Jl133+FZUdKGobA6OGEVRNXCjQL
         bxIg==
X-Gm-Message-State: APjAAAVqyHlzXQbQ6KymlgJhV45I5OtqS3yXkidlwpwSMuAPNdCP3Q4v
	nfTh3Vi5an08AYSLG3fvAOwBvR060NpaotUvNYyuOlUKzCVGkKcpAaUOkh+hUXySziYAHr2Qn7Y
	VhvDMOJQol0M5av8fe4sZC5xHytxyGY1JTUSG+E9c3f2XPlqLYPWD0RFLeSRStXARgg==
X-Received: by 2002:a6b:4408:: with SMTP id r8mr9093941ioa.135.1556199401520;
        Thu, 25 Apr 2019 06:36:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcuHmIK5cLq6flfXFAckq0Cu+fWZR72AMMUKNDsfIprrXgU5wqOclLHMmKCOgAPJvjDoYS
X-Received: by 2002:a6b:4408:: with SMTP id r8mr9093906ioa.135.1556199400759;
        Thu, 25 Apr 2019 06:36:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556199400; cv=none;
        d=google.com; s=arc-20160816;
        b=ce7sRfd3Q2SjPw1fNitvgCsmxkKXO0aM+XofIyFH3nUb/J96DUj7iEjdyDBW8WYsEJ
         0COWN0eCz3B4qyux5aTLO0E6MDXI+SgouZrhYqvlTeaf62sbIJdj2xyVuQ0OZaaEGkap
         hSIWg5vSiBsBv0CULhauiiIhj0E5A+kVSpOj+XYJ/Rd33jOxmSq7HI62rPSNoDAeiecD
         VKdRsQsYvMvB35dFIwVPi8SM9Ihpiza/fSElHxV/SxxEe1HEici4w6s4UTOEM/xBB8so
         s4lXgKh4zKodNIJONbhq2tQLkwFXAExUAiO4+xELhNjtXa1bwhLw+6HZoJH6GIYm11aa
         +3gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cilSacm49Yfv3yMpgdaQhWv20ykDrXiN3MsGcQ6O+1Q=;
        b=qwTvvX5N0gV1CL3d7QzK+zxY5zCe6Q2/231KDBO6SKYaG/hC13BtiQusTgSRHEPGXg
         GK/0/t3JOpygBdmVkFEOMdD6tLcMbkUpxJt2142jgxj0aGAykQoY0YjsaWhkDcNt7OrR
         4kEO79M9ifNcqHH65noQBeY/xMK/k53nKaBhcQ1SXHp4oQaWcMK3wphCBdckh5+XUOjx
         OT7le5L+Nhl5uXycVt4PtmgYtgu6M0AUqcQyBrwiBMdtKeXChg5sVzEvFK7Y2DxSNSR9
         jpNcFPegWAb6z0+sYlTcl0Spt2iIAO1i+Fm/3AovS3J62DMUmbpdAW5Knbz90en843mL
         xE8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Gg0uxuaD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a11si14032627itc.69.2019.04.25.06.36.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 25 Apr 2019 06:36:40 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Gg0uxuaD;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=cilSacm49Yfv3yMpgdaQhWv20ykDrXiN3MsGcQ6O+1Q=; b=Gg0uxuaDkYyw6kLrTrmTd2Sw6
	n+aNn/QLc2hEIkZ+/ND8NCAnx6RF3fW2lY+PUWBDA2fBhd0RhUhI1eEXKmbrCpT9ft93CfFlCkdyS
	RsNaDcB8XRunkoMdHJa/Htvyj8Px3d27BsqqbESaKXlrlD/+2rF7pc+ifo1QfuYavEJnvemrFz+Jv
	dKAF+mzv+IFtIpqqc3hyRPwsKByzhFVdMmp+5/96EfVNDqR+LsVcYmUtPdvbtBtw3S0CnVr7FSuAZ
	N3A+tBtSgyIwKYztPEjfIl8x/ClV/RJt6CmRi1SRp+JXV9A53CkNFOQ58LOdj1ON937bDh3YmgcWm
	dM4fhMzaA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hJeXY-0004TE-0R; Thu, 25 Apr 2019 13:35:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id 147B82395002B; Thu, 25 Apr 2019 15:35:49 +0200 (CEST)
Date: Thu, 25 Apr 2019 15:35:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	linux-mm@kvack.org, David Rientjes <rientjes@google.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, Daniel Vetter <daniel@ffwll.ch>,
	intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Miroslav Benes <mbenes@suse.cz>, linux-arch@vger.kernel.org
Subject: Re: [patch V3 18/29] lockdep: Remove save argument from
 check_prev_add()
Message-ID: <20190425133549.GW4038@hirez.programming.kicks-ass.net>
References: <20190425094453.875139013@linutronix.de>
 <20190425094802.803362058@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425094802.803362058@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 11:45:11AM +0200, Thomas Gleixner wrote:
> There is only one caller which hands in save_trace as function pointer.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>

