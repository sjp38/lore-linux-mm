Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 616E9C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 13:29:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 279862084F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 13:29:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 279862084F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BF6B8E0082; Thu, 21 Feb 2019 08:29:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86CF48E0002; Thu, 21 Feb 2019 08:29:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75D758E0082; Thu, 21 Feb 2019 08:29:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 322BF8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 08:29:19 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id a21so10361725eda.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 05:29:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=U9ehUWdTcAy0ykbJkopWYPfVlTBbalzLPRxT1N8hJZ8=;
        b=pWMAQDAvuEKOKBvl5cfDXur8gdOx4kqEpH1CXMFohpHbc1ufvjh9as9wprvAQc4RQh
         IvoSXDOK3mphRDHIykyexhmJoF/OZ9rGF//yI7BgRqC3wBrmCoyEhaK9UBX2fJMnLDSD
         xqydM81/3TPGbTwcHz94z8+/GQYXJhsQTBBYkUbKaTPovSYmYRrUU7OEmjoTuM8T4okm
         paItX+nRv2VpOpzBk44WCIFGYVqFCpb+OD7iUrSsBo+RmOPWuxqDfyONk5Xaao42X1dy
         T9XiGR7HWrfOyCydT5cYPFPapos1sdcrPu/PZWoNKipr4Q2GvuPbdpLprVP7EzS8Jjs9
         2Rag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAua6mnxW8uN4tfWhDQIPVFsV/JL6CXINAke5jW820fgDiyCaVFS8
	knvycrV4pAFRynq/Zl4c5aF+8/s6dnlJidE9hrcmez/JrcoGkpyq9eL8fLE52wntQvETmlpHtPG
	f0JHtmBaaRDt91QsSdZaKZAIHJZr8gAx7syNvD4/T+g6DpJjffUR7mnMa5mr64L/QoQ==
X-Received: by 2002:aa7:c254:: with SMTP id y20mr19427029edo.40.1550755758759;
        Thu, 21 Feb 2019 05:29:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iaq9FDw2pROrY6DmcuL3RG5LgxLZvcKDo6VZ+2NHvHfmbQcFxZJxxak+XyzbColEUU69636
X-Received: by 2002:aa7:c254:: with SMTP id y20mr19426971edo.40.1550755757849;
        Thu, 21 Feb 2019 05:29:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550755757; cv=none;
        d=google.com; s=arc-20160816;
        b=xGlt7nxIX9beTKmXwkvxalXa/z4WaMETIcSU6TgKfJH4JHU8NkE9J5yrYi7TlHMiI0
         CvvLjXY8ESCxcWa3MWNyS1CAnnqPeGLl9I2urh5awyBrLVToZ9jua1NlcEyUDJBDQ8qm
         sRuv9N1dWT+5itBxy9Se9tR2fx4XTNTDPRAWkxip0aqnSfbQOsF4dK+1mplxfePZRZsg
         SFJJuulgGlAL6UIiDDOs7zjIQrYkGCdviyPkcemUzQWGHprOm53bWrax4uXIMwR6zZn0
         BaNxHiS6FFtertDd7qeHUtUL4+cB31DZ9HtuedECd4LvzN07Wo3bqzmP5O6TJEotVIyZ
         n+VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=U9ehUWdTcAy0ykbJkopWYPfVlTBbalzLPRxT1N8hJZ8=;
        b=ENBq6PVMWH+goM6RKBt4/1dq2RcP2paqzsKZbnzaaokGlWyExKdR0H0GS5SX6nQ/h+
         NOaIqV9BVFLP1fpNoveyI8AEGPwgEClmpdw/V+lO0N1Mh0/QmdVrblxBnSLMzbQqeAWO
         WILG9i24QC7Q8hpfyLNBsVr4blF9iy/wOAfheQChlfmFKc3w4FIJolhjFajnEA+FHVa0
         rUX4PEtbSVXCtYc5ULiySX3WtcgEfpWGD2pPr3FJUG+wOT1UhLjvKcileUEvGxey48F8
         GwjWthuAulRO3OqsOI4I7FpPo1Q0bj65C0Ka9gFgVTd8tlJUSJK9aS5F+ypTdMmooJg9
         n99g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z11si730139edx.149.2019.02.21.05.29.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 05:29:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D5B5DAF94;
	Thu, 21 Feb 2019 13:29:16 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 49DCC1E0900; Thu, 21 Feb 2019 14:29:16 +0100 (CET)
Date: Thu, 21 Feb 2019 14:29:16 +0100
From: Jan Kara <jack@suse.cz>
To: Meelis Roos <mroos@linux.ee>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
	"Theodore Y. Ts'o" <tytso@mit.edu>, linux-alpha@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, linux-block@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: ext4 corruption on alpha with 4.20.0-09062-gd8372ba8ce28
Message-ID: <20190221132916.GA22886@quack2.suse.cz>
References: <076b8b72-fab0-ea98-f32f-f48949585f9d@linux.ee>
 <20190216174536.GC23000@mit.edu>
 <e175b885-082a-97c1-a0be-999040a06443@linux.ee>
 <20190218120209.GC20919@quack2.suse.cz>
 <4e015688-8633-d1a0-308b-ba2a78600544@linux.ee>
 <20190219132026.GA28293@quack2.suse.cz>
 <20190219144454.GB12668@bombadil.infradead.org>
 <d444f653-9b99-5e9b-3b47-97f824c29b0e@linux.ee>
 <20190220094813.GA27474@quack2.suse.cz>
 <2381c264-92f5-db43-b6a5-8e00bd881fef@linux.ee>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2381c264-92f5-db43-b6a5-8e00bd881fef@linux.ee>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 21-02-19 01:23:50, Meelis Roos wrote:
> > > First, I found out that both the problematic alphas had memory compaction and
> > > page migration and bounce buffers turned on, and working alphas had them off.
> > > 
> > > Next, turing off these options makes the problematic alphas work.
> > 
> > OK, thanks for testing! Can you narrow down whether the problem is due to
> > CONFIG_BOUNCE or CONFIG_MIGRATION + CONFIG_COMPACTION? These are two
> > completely different things so knowing where to look will help. Thanks!
> 
> Tested both.
> 
> Just CONFIG_MIGRATION + CONFIG_COMPACTION breaks the alpha.
> Just CONFIG_BOUNCE has no effect in 5 tries.

OK, so page migration is problematic. Thanks for confirmation!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

