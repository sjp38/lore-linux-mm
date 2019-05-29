Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A521C46460
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 06:11:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F34D2208CB
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 06:11:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="C63n5tH5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F34D2208CB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4897A6B000D; Wed, 29 May 2019 02:11:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43A0F6B0010; Wed, 29 May 2019 02:11:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3028A6B0266; Wed, 29 May 2019 02:11:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E971C6B000D
	for <linux-mm@kvack.org>; Wed, 29 May 2019 02:11:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id f9so1113962pfn.6
        for <linux-mm@kvack.org>; Tue, 28 May 2019 23:11:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Ki8wlzJaAXUMUjbjK207hScTMszow2OB9kp3Ebyx2W4=;
        b=M0nWp/YJ2I1dMceb0yXK8w5/lPnIxj8KrQ610kL3S4YRqeL5YlNOpiUQMVWLSY8//t
         PFXY9r33hOGflM3eyUAHW/5jlG8cA2KbpCIRzZhZ7xEIfI7HJnxWWjws4txReL2pMoZI
         yVo70LYWcs0sGjjEX1R7dLhwnZdUIQ40zwxUsU1sJ53LGxijoTuqZ/7B++zTr+xVKIFF
         4kMhEknRkxD5p0e1BN7y1njTfTpycNMLdPBB/hr7ZBClZlFXlngMc6M+cGzWdlJF19aY
         SOAvvgn4AXntVIcLzXdy8Y38tUa4c32zK6jkKDz8r/YsbLLWDg3+UMIQvmgwIpW8I7us
         xvAA==
X-Gm-Message-State: APjAAAWRGixlyhJ1VNvO3/8DcBc4Abh4pL3FcdyZl795B74zvQgBEGLb
	33FpRktjmnpME1fIm55U7z99TOluAdG6UyfHAzptTaDxKsjtnXues9wp+kyTTR65BsRfLmXHByU
	JGKVhp5WPwRlXnWw+JsRM5n0dEOYSe92PjjjqrXrQTInBeFCDRY681MIYVKc8/12ICA==
X-Received: by 2002:a17:90a:9d83:: with SMTP id k3mr2186638pjp.105.1559110296519;
        Tue, 28 May 2019 23:11:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn5uptbEDjfXVrWSIcxbxU49rhLbhshr1nDprRS9ORAi2e+UZ2U2hzyHNnuxLPgjbpRyni
X-Received: by 2002:a17:90a:9d83:: with SMTP id k3mr2186582pjp.105.1559110295534;
        Tue, 28 May 2019 23:11:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559110295; cv=none;
        d=google.com; s=arc-20160816;
        b=Qu9OZkZFFVG6kXL1bvZKFk+qwPkrN167wvZ8VLpdetifpqcugKJbA6VHm2hmsCWKPY
         2MejDwKFSXwdy8gLMrK3Y8KpI3XEP8d+5s8FYwh00i3Hai+YCLJCMF/lIw2QapASEArQ
         v4O29usrsPX0MBJ/Rbl8IobmDgm2oZXrj3v84RDbqRwt1Po4YtW9TyCFJRvm/skSl0Cx
         wC8GER2brMIXaH43p6bYd1gLC3pxjSeeiNwLT/LK3T8SxEOVoGWyJjsKIzaRtSt+HvbY
         9N0D6zJZ1ORrOOfi+5Y/kdXAkBkNG4uCJ/3yT1XXeI3V1Qk01VNNiX0Q4bFkjUEwHsUE
         OGoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Ki8wlzJaAXUMUjbjK207hScTMszow2OB9kp3Ebyx2W4=;
        b=Sx0K8C2vQYOy/nUGnKB7IbYRy5LQKRos2RTOdUEASSn38tx/G6qedQMZiFPIcFXIc/
         mEXcqw9Mz5WJyy9Mx22b+ioemzsPQLVGPpKZtrwfdMCN5d7BN2SituLPq+FXXXHygCBF
         /I9Zc2a663RNv6zbl8c1wVpn1GV7xcXckYXQ7OdLSV6CyGyvzhZvx8cx3Ga2qkzKBCAx
         VLYux9vqtZWwueFQoOP8Xe08QWhfm2NKI/0/x49zmnb1CvTtoXNpEktSn0xG0fciLJrR
         95Vsbe1NMWlu1ZJzfsQGtd/SlmM7J1hYKCBSk/qsGQKhr1UlNVoTDT5QAkch9rUATQ1/
         orcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C63n5tH5;
       spf=pass (google.com: best guess record for domain of batv+6b2e7d6ba9248c696ca2+5757+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6b2e7d6ba9248c696ca2+5757+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y125si28227293pfb.115.2019.05.28.23.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 23:11:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+6b2e7d6ba9248c696ca2+5757+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=C63n5tH5;
       spf=pass (google.com: best guess record for domain of batv+6b2e7d6ba9248c696ca2+5757+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+6b2e7d6ba9248c696ca2+5757+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Ki8wlzJaAXUMUjbjK207hScTMszow2OB9kp3Ebyx2W4=; b=C63n5tH5sy21OVy69pE2Oeedi
	R/8G/O4R+cqkOb+iay2A6/Ut98QvmOoVxDkFq9W2+7U/LqR+H8f2OYu4N8PPxCiXmTn6+ZCacke9R
	NiVaBNHylJKbX5saC2PVaMZWgJI/vqUasbLHzdYAaf6JMJZnN5dnuUb+xuFqzNQ1JfxCcFuQJ4xK+
	6qWDzjNi2j3o36d3TPB8w5XNqN0HcN+Qs09ffRNSsIKDnPfv3T/Ev6qXrq/Wr6gPHomkX4l/KvNpH
	N2TnBmCl3vuVelWduaIB1cfkd9FE3VcX3LaRbJyskNDE+jHFkxAKB3R4p6SImibWTKLIlWDTUm7UG
	kjPLjC7pg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hVro6-0006Yh-Is; Wed, 29 May 2019 06:11:26 +0000
Date: Tue, 28 May 2019 23:11:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Evgenii Stepanov <eugenis@google.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Elliott Hughes <enh@google.com>,
	Khalid Aziz <khalid.aziz@oracle.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190529061126.GA18124@infradead.org>
References: <20190517144931.GA56186@arrakis.emea.arm.com>
 <CAFKCwrj6JEtp4BzhqO178LFJepmepoMx=G+YdC8sqZ3bcBp3EQ@mail.gmail.com>
 <20190521182932.sm4vxweuwo5ermyd@mbp>
 <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com>
 <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com>
 <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com>
 <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> Thanks for a lot of valuable input! I've read through all the replies
> and got somewhat lost. What are the changes I need to do to this
> series?
> 
> 1. Should I move untagging for memory syscalls back to the generic
> code so other arches would make use of it as well, or should I keep
> the arm64 specific memory syscalls wrappers and address the comments
> on that patch?

It absolutely needs to move to common code.  Having arch code leads
to pointless (often unintentional) semantic difference between
architectures, and lots of boilerplate code.

Btw, can anyone of the arm crowd or Khalid comment on the linux-mm
thread on generic gup where I'm dealing with the pre-existing ADI
case of pointer untagging?

