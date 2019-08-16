Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B68FAC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:23:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7735B2086C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:23:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="PKOKEY8h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7735B2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 287116B0006; Fri, 16 Aug 2019 13:23:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 210A66B0007; Fri, 16 Aug 2019 13:23:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D7726B000A; Fri, 16 Aug 2019 13:23:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0073.hostedemail.com [216.40.44.73])
	by kanga.kvack.org (Postfix) with ESMTP id D9B876B0006
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:23:28 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7AE65181B048A
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:23:28 +0000 (UTC)
X-FDA: 75828962496.27.balls35_1e47315aacc56
X-HE-Tag: balls35_1e47315aacc56
X-Filterd-Recvd-Size: 4026
Received: from mail-qk1-f194.google.com (mail-qk1-f194.google.com [209.85.222.194])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:23:27 +0000 (UTC)
Received: by mail-qk1-f194.google.com with SMTP id 201so5299691qkm.9
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:23:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pD8Tbdojb+tV/T42U7/Bt4fJei4dk6nxHPESNZBzUPg=;
        b=PKOKEY8hGxaOdpj1T8hBrDGYtsUrnU0AObkNmorj7jn7hBXpX2Kp/ztvI9DGVCYTQE
         dc7AfGY5084FNsyK1iFgRwps/IMRwPx5SDeHZ6iG6Vx1Auh9Jiwqi8IwIFgmkC1IyaaP
         ZG/0N27IRdZCGF/hPvMRXRbsTrG+8jAJ2xVMkv6g6aeYSe5QxCHrQ2ZmirGBi7NhhAtL
         8LPoo597le/ShD9ep2nuha5j6xRqGlB/XWU5NWICIfVLLTfLX0mziYqsaSh3ZaTmUF0u
         cvAphTs2Z1DvPDJOzISG6/SYjf5j85EYdPNZa7ztM4aMs2xfCrXlpdbNpKuWGh1E+PLB
         PLqA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=pD8Tbdojb+tV/T42U7/Bt4fJei4dk6nxHPESNZBzUPg=;
        b=XumYUJTsw0iM3Phyt6KI+CX/WphmEU/8ZM+qUx8IDKF3Ocj+iKxg4QhjhRlXfniUqC
         FhQa7/PAmmmi4KPPQtunfO0i91eZcmFzOkGYUPAB6jJiIRoGZbKrQ0K17n87I6TydYHj
         8C61rfEUtYXm7x240e8FOUTA2ujW0KE1lJFws73t/tevGb/6IeEPhx4QHkkkeSBr5bpL
         4ADAhKdDfL8SjoJcoGRSmq7o4jhRLJRX1YGSBpNOlNSBy/zRjcobDnr+jvVHRPJoCVQc
         XiUeJUFA7DQ7i0lVRJUiB1oUI57EPXcZDrMeOK90By8JPpyJPwtAXnVSD8famYSoA/Ga
         uoWA==
X-Gm-Message-State: APjAAAUt0sXt4IMWwUQpr87oC6OEh+HFdqgoaq3gdYAdPDYRACCRsVZD
	urT334RNGlC5wCodrlZ4qX2ChppalgA=
X-Google-Smtp-Source: APXvYqyAuZxMtBrIj2lrXbWPNUHVpEBKMq4p2dvILNeEBwhH8SLFMps9jaKCtPjbt9+U/fOmx5c77w==
X-Received: by 2002:a37:805:: with SMTP id 5mr9982722qki.351.1565976207466;
        Fri, 16 Aug 2019 10:23:27 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 23sm3185723qkk.121.2019.08.16.10.23.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 10:23:27 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyfwk-0000tb-MA; Fri, 16 Aug 2019 14:23:26 -0300
Date: Fri, 16 Aug 2019 14:23:26 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: turn hmm migrate_vma upside down v3
Message-ID: <20190816172326.GI5398@ziepe.ca>
References: <20190814075928.23766-1-hch@lst.de>
 <20190816065141.GA6996@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190816065141.GA6996@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 08:51:41AM +0200, Christoph Hellwig wrote:
> Jason,
> 
> are you going to look into picking this up?  Unfortunately there is
> a hole pile in this area still pending, including the kvmppc secure
> memory driver from Bharata that depends on the work.

Done,

Lets see if Dan will comment on the pagemap part (looks
straightforward to me), and then after we grab that I will declare
hmm.git non-rebasing and Bharata can build his series upon it.

As a reminder, please do not send hmm.git inside another pull request
to Linus without making it very clear in that cover letter and Cc'ing
me. Thanks.

Regards,
Jason

