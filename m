Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDE6CC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:02:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD1820B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 18:02:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="dmyRhMBZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD1820B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 405016B000C; Tue,  6 Aug 2019 14:02:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B5F66B000D; Tue,  6 Aug 2019 14:02:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CB616B000E; Tue,  6 Aug 2019 14:02:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0BC026B000C
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 14:02:50 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c1so76380060qkl.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 11:02:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=J340zbxKrZwPhKQPn9TeC4csGhsk958SAmRA1+an/JE=;
        b=oIAEw7V9pmri3PzzdGOiJcJSODI9GVr4lVtXA/NnlHUj4RdMVQerwv91RHkMggdjcr
         uvaKsTF4wVBPvsOMQLJeMUWn0kE3n1iZ4kOT7mxBf5XmjojDN9vCi2vAWY8KDVJf43Ua
         UEIMKae2PIJnc+qmfudGWG8K1auIVCATkfmEe7y13pzsk7sxyB3MrVrTTJIBFRYSMqEa
         4+wcQaf5LPwFERl5o8eRzHTjzYAJGS7ngzCyjUJOuKFGq9PTzk8S80VVvnx7fuUXosSB
         WqpfQhGX+ednAYIsjNWUpag0nbQ1DzG7G6cBVuMggoFJ3E6Q7KhzG+lQX4fFi71HQLBP
         JCow==
X-Gm-Message-State: APjAAAUJLSxm552mIPCM9wyiaCj80uNjF07oc3ToXWFCOP3wii4gPx/e
	3diRZ+YvImIM28s1SbMkx4z5NvErHWOoDHHa2GxpDoanatQ6RcyzBDPXeh7He53PLL4wLPvaz+N
	G6BimVGGjqn7bVKJu55vbZG4CDtV2wa894vc4cUIZZ1YoX6a+mPinBueAnHdkPRq5zw==
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr4179024qtb.47.1565114569852;
        Tue, 06 Aug 2019 11:02:49 -0700 (PDT)
X-Received: by 2002:ac8:32c8:: with SMTP id a8mr4178985qtb.47.1565114569466;
        Tue, 06 Aug 2019 11:02:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565114569; cv=none;
        d=google.com; s=arc-20160816;
        b=J/PFl6gI3t6eXa/b9PvYwKJpbbErhZrKGoMoFlQx2xeH2Nq/6bXOM76nbsmlxPwwl5
         Vws8kgsGX6tl5u5Hjs77jsL+iXd5svP0siZ5nB+yxF3qN8pr6wYkJ92lQBLRbmvwX5c9
         J93oc6s7/YvPCpG6JVEmx2a+MDnP9IvinuaUEh+E8rxoQ69yauO1KUYsj8p3N6wMYjQW
         Fai5p9QRvEsLQJ+jA0YLFhecycTMAvjo9TmPsWCLpY6t/hO0AVr9VTXGPztzqRTxExBH
         xWGESrGNBPad8p9XWl++E1wVOtw3/hBehFo0/VHKcVmHSy7g+Mc3iJcgdRYORY9ruo+O
         o8UQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=J340zbxKrZwPhKQPn9TeC4csGhsk958SAmRA1+an/JE=;
        b=KG4sdc0H9dBaBn4id8BCkq1r5eeWWuEiayXiu7ExPEN4eZ+p4ZVs/r6ClB5dg1TDwB
         HPNqQhu/0uh2NsaHwSd6+UntHfNDmz4qGzuJMzuvSRiyxS8IIKq9goszfmGE5onZ5vDc
         VjnYRA5qD2QkoKPWz44EoHzf7kwLU0WjhHD5Gq+OI/BTlHW5XIWr2BBMJ3S1zW5jexia
         hiux6lYud6Z9O8EtodQGJGDLIQFMpnKjb+DIpXIShS46u9kU4WbRpSCPUY8ZYfJ7KeJf
         bB4LW+qbyqYML4OtIaTbgUwAXhVGhKucWGHgDefBOZoPF6FanwygI2ooYVx83ApksXlq
         eElw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dmyRhMBZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14sor49546309qka.115.2019.08.06.11.02.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 11:02:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=dmyRhMBZ;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=J340zbxKrZwPhKQPn9TeC4csGhsk958SAmRA1+an/JE=;
        b=dmyRhMBZI6zY0I2u7wdyHQjMKNx7X6q/44JyGKfb/VDswyFMmZFRkfFHuwa6xb9W77
         /60SemHut0sNFpXi8VWhLEujUvdmhIPrdRNkn3/J8WP+d2+9yM+59k7uYRD0oXqoGmkv
         AdAgySgMZPnuRZQMrufc/1lAUL2PUjg7rsZvJGuL8Mj2mTI3z0O2wFRQECzd2fD6TiTN
         BOs8Eu8913OI8Gc+ity2XD16jj+X32RK4PRj79qKdpLBOcODvMrV18XBvn3mOzh3Diqj
         awOnPn2b4LSHKJWlA/RvcCNCNU2eXDwXISITGSPgHG1GksuEOvVSXUJKrqxO2IQiTL/B
         Xh+g==
X-Google-Smtp-Source: APXvYqzeVullh9O51A7m3TZsWYHDgm0ndSlca+disOdIT8zFGqnFmyETv0vAgxjYTLrTqv0QWoZpMA==
X-Received: by 2002:a37:7704:: with SMTP id s4mr4481690qkc.310.1565114569197;
        Tue, 06 Aug 2019 11:02:49 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id c18sm6024222qtj.25.2019.08.06.11.02.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 06 Aug 2019 11:02:48 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hv3nM-0000IY-6M; Tue, 06 Aug 2019 15:02:48 -0300
Date: Tue, 6 Aug 2019 15:02:48 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 03/15] nouveau: pass struct nouveau_svmm to
 nouveau_range_fault
Message-ID: <20190806180248.GO11627@ziepe.ca>
References: <20190806160554.14046-1-hch@lst.de>
 <20190806160554.14046-4-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806160554.14046-4-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 07:05:41PM +0300, Christoph Hellwig wrote:
> We'll need the nouveau_svmm structure to improve the function soon.
> For now this allows using the svmm->mm reference to unlock the
> mmap_sem, and thus the same dereference chain that the caller uses
> to lock and unlock it.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/gpu/drm/nouveau/nouveau_svm.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

