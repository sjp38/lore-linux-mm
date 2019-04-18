Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53B59C282DD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:17:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D85C20651
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 15:17:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D85C20651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8381D6B0005; Thu, 18 Apr 2019 11:17:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E6D76B0006; Thu, 18 Apr 2019 11:17:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B18F6B0007; Thu, 18 Apr 2019 11:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1943B6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 11:17:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k56so1432156edb.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 08:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wDZDD/f2hp+a/qiszZ323T1I8A4Ne2aqfzbI95NxmpE=;
        b=U8yDILwTUgDA3g3M14kkgPPr3eEfKNAurotn7PbDB/okENeOs559TIxbL545qbt/Im
         sYKOgcZf2JfY3bHEX3KT6zjQhlckT5rErkYV21ewvuOUFJrK3FSmxQ2W0ZwG2P3xqc9G
         mRBKdwgzaar1Box0lucE5xnOmAksZTSl/UQi1NoPxk4cQDuyQENM0ofjqdcyWJf2t7K5
         Gp8HfZwjFTGlvKbck/MLqPee3U/YQsCZfzocRBiK59kRvYilxr9/NbJs+6MJ/TyZTqkO
         JEE6ISo8+dPWErjgNSg3SlgOPuSK+xjCbiCMWw8LX5RCvqJ2dqd0mdx/2yNo0AOxO9LM
         aNrQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAX67icJadirHlxOBQ3COYM6kJ5a0hZjiAzfh6+2pah3EeJ40bMr
	sYueQVEPJNSsbMIH03Uj2OWn/K7wSU9dhTYkcZJD6h+w5EyXLaTtmr2Vzrxi1yk9q/3wXY7CiA5
	B/RYR+wOvO3Kjl1OKgr9Mpuq6r1WguMJ40GiLxEfNC/oNeSrLhK8HduYL5a8Ddcctbg==
X-Received: by 2002:aa7:dada:: with SMTP id x26mr25235449eds.77.1555600652500;
        Thu, 18 Apr 2019 08:17:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyn1yRNRNwbg6h8HkWq54nmf3y7dU36MGesNWXJu52dVT1OqGdnkxPkGdDL4BBiL64Z+x/p
X-Received: by 2002:aa7:dada:: with SMTP id x26mr25235391eds.77.1555600651631;
        Thu, 18 Apr 2019 08:17:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555600651; cv=none;
        d=google.com; s=arc-20160816;
        b=cWfYIOFGbfTabT5sD7xW3xHzbc7r8KIHO1ppQXFE9UnY9B5/ow1J7eJMlQzVIra17q
         KZCGOHQ0rzXe9CNQwRS1OD+6+GFa4Tx5bXwphKxO0G6ec63oshpWHeBEatP/fwG/QloD
         8N40iI2coP6nJo4RTm6FW45GjoToYZUA0DvtV4pc5FNYtxxm3AYQF/9TahpdwdccEleN
         WgpfQwKMT4yK8dtCKxDf3DJNRxfxu6iMLoXRUB4V4baHspYu/SkLPV3eJqLHZqLhhf3B
         9zNEnC2oiXX5jKEEgNgSYHJKoFLKv4hooyJ6xWWwfINjRE+ClRiRqe86uG5LBNopxRo0
         3vnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wDZDD/f2hp+a/qiszZ323T1I8A4Ne2aqfzbI95NxmpE=;
        b=jj82EasVr419In9dOOPwwNZHeKNsd+cQHBio8oYUQSD50MhIcH4uD4wtKYa58Sk4vn
         zgrL65nFtSaCz7lPw9KEqjvsI9Tn86GbX57oJAM+OS96bHO/85Qyt5xNmjgZaOSeRmjy
         VQA+VW0q6rGd00a+9GUdmpfTSwHskI6s4zy9wcr95F+rgHAh4AYrhUpWkAuTZQz58vA3
         sifYXhD8NKoquCMiu5TVB5fKT8Nsl7lIRFLp85EZ1ebHdKxWYArSURMGVZSt7tQ8XyeU
         f7ao+Jj1TcTTaZnE6AIusG8Un/q2NMmZW8oop6ivKHZsIpUqwNQO5cskee/WqjN7ca2t
         iAJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g2si305446edh.410.2019.04.18.08.17.31
        for <linux-mm@kvack.org>;
        Thu, 18 Apr 2019 08:17:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 84DA015AB;
	Thu, 18 Apr 2019 08:17:30 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 86C8F3F5AF;
	Thu, 18 Apr 2019 08:17:24 -0700 (PDT)
Date: Thu, 18 Apr 2019 16:17:20 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Josh Poimboeuf <jpoimboe@redhat.com>, x86@kernel.org,
	Andy Lutomirski <luto@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Alexander Potapenko <glider@google.com>, linux-mm@kvack.org,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Christoph Lameter <cl@linux.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	kasan-dev@googlegroups.com, Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Akinobu Mita <akinobu.mita@gmail.com>,
	iommu@lists.linux-foundation.org,
	Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	David Sterba <dsterba@suse.com>, Chris Mason <clm@fb.com>,
	Josef Bacik <josef@toxicpanda.com>, linux-btrfs@vger.kernel.org,
	dm-devel@redhat.com, Mike Snitzer <snitzer@redhat.com>,
	Alasdair Kergon <agk@redhat.com>, intel-gfx@lists.freedesktop.org,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Daniel Vetter <daniel@ffwll.ch>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 08/29] mm/kmemleak: Simplify stacktrace handling
Message-ID: <20190418151720.GH18646@arrakis.emea.arm.com>
References: <20190418084119.056416939@linutronix.de>
 <20190418084253.811477032@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190418084253.811477032@linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 10:41:27AM +0200, Thomas Gleixner wrote:
> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: linux-mm@kvack.org

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

