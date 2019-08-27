Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38C44C3A5A3
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:04:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB7B32186A
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 23:04:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TXlm0q2x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB7B32186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79EE96B0006; Tue, 27 Aug 2019 19:04:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 775D96B0008; Tue, 27 Aug 2019 19:04:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664DE6B000A; Tue, 27 Aug 2019 19:04:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0115.hostedemail.com [216.40.44.115])
	by kanga.kvack.org (Postfix) with ESMTP id 434496B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 19:04:46 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B074E180AD803
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:04:45 +0000 (UTC)
X-FDA: 75869739330.07.pail00_c6e2352ef253
X-HE-Tag: pail00_c6e2352ef253
X-Filterd-Recvd-Size: 4307
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf27.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 23:04:45 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id m2so707376qki.12
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 16:04:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=twfAj3jJ2iISvtECbV5aZw57c7oT5wmcKVNF5jtBKzw=;
        b=TXlm0q2xcS7/T/OenFpz5vi4Yo1hovc71pjCHSJFZtpy8c9XUnNxETQI04ONVL0JIb
         xjCg1ybda4kro9E97QJSZSC/ihNDktOyYrdT8R26XLgljCtsNC1Vrq1jHptibE/6c1Nf
         EnImq/F6CeVQdv8DhnroTOVUgpGI4Q53Tzi+7QBPIjjUtOvPjrzPVX/jcKew3UlbKL90
         uUttussOAeggtW9AKfycy76g+BnNBWpDYxb+G9wjbjpqMtDqXs7hiScwYsQlSR3G6afw
         kwtNsqYgOSibPsNyIiq4ivvhuJDj/CXdeSuB6tWCMVfMG0Gr1JdzT+6jpEuRLfpulGpr
         muWg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=twfAj3jJ2iISvtECbV5aZw57c7oT5wmcKVNF5jtBKzw=;
        b=oeozBoF1+UQnx3/wskw3zjs0h9lo4R4fxPPMbNylOxui7/unc/f0mvOkEOva4zU+KA
         T1H1XnJq8XnAZhhfIrAjUNDyy951PBEsX80mrOswJC58+0dg1BngWagQIkASX49ohrkM
         wSVJtyrzE9rGQQaUxmq/DF3SGXU4WZDy5EMaiEGX1tHWFS0gVQTjHcT+ijONkM3sNc3X
         /vTFoD7ZpSeehRw4n3Qio7NymHKKozNvEmny+0fNsv3rXXRj1JiQskNURCrTXqYkzBFy
         Hd1JVWi/B5mIpyd3Bhrn0RixQzUh3EWki1bOzqa30lu3rBtCx7ZJk4/LGY34T9QEtsid
         Uw0Q==
X-Gm-Message-State: APjAAAU+2SdCpiTCrP63+oUAvOiku0C10y2cNy58XtCXblwGKk2OyGVL
	ne3G4NT4dIQ20qS7M2ySzK0t3LfvVwo=
X-Google-Smtp-Source: APXvYqxETSoB7i089gEAZo3heQkfBeRm4nuAsZXEBqnzkt2y4Au7XwxwXBZ3oa3XifiOiixuSCRIRg==
X-Received: by 2002:a37:3d8:: with SMTP id 207mr671091qkd.191.1566947084848;
        Tue, 27 Aug 2019 16:04:44 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-142-167-216-168.dhcp-dynamic.fibreop.ns.bellaliant.net. [142.167.216.168])
        by smtp.gmail.com with ESMTPSA id u28sm319212qtc.18.2019.08.27.16.04.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Aug 2019 16:04:44 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i2kW3-0007TV-VG; Tue, 27 Aug 2019 20:04:43 -0300
Date: Tue, 27 Aug 2019 20:04:43 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>
Subject: Re: [PATCH 0/5] mmu notifer debug annotations
Message-ID: <20190827230443.GA28580@ziepe.ca>
References: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190826201425.17547-1-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 26, 2019 at 10:14:20PM +0200, Daniel Vetter wrote:
> Hi all,
> 
> Next round. Changes:
> 
> - I kept the two lockdep annotations patches since when I rebased this
>   before retesting linux-next didn't yet have them. Otherwise unchanged
>   except for a trivial conflict.
> 
> - Ack from Peter Z. on the kernel.h patch.
> 
> - Added annotations for non_block to invalidate_range_end. I can't test
>   that readily since i915 doesn't use it.
> 
> - Added might_sleep annotations to also make sure the mm side keeps up
>   it's side of the contract here around what's allowed and what's not.
> 
> Comments, feedback, review as usual very much appreciated.
> 
> 
> Daniel Vetter (5):
>   mm, notifier: Add a lockdep map for invalidate_range_start/end
>   mm, notifier: Prime lockdep
>   mm, notifier: annotate with might_sleep()

I took these ones to hmm.git as they have a small conflict with hmm's
changes.

>   kernel.h: Add non_block_start/end()
>   mm, notifier: Catch sleeping/blocking for !blockable

Lets see about the checkpatch warning and review on these two please

Thanks,
Jason

