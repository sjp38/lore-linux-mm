Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAD38C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:21:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ED9520675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:21:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ED9520675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 085078E0003; Thu,  7 Mar 2019 21:21:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 00B8A8E0002; Thu,  7 Mar 2019 21:21:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF05E8E0003; Thu,  7 Mar 2019 21:21:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B120F8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:21:07 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id g42so1276110qtb.20
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:21:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=2TXa20qb/Eg4W3WSZnBQT88vOwNyfmVbxryiRAAOMZ0=;
        b=QBlXLPwS709kwLiYlWzRjbe7UfS3Y3EoJdvbqkjf2mVjTxAOaUgAo6gYv0OsfUUAWN
         TJn7qtI6VwXk8qAICqG1WjkkO5wvbgFE629lqAbRVtQz1bUKb0Ln7h4NMqAf82uaTOK7
         dhA1Q4O53maTjXa1jevNxCM6doNvVIBBVcMLHPf+xWTFr/+YsJypR34rdAfj/qq12G7r
         e1FiByA/ha01doSQ+MUX1lQUkW7hjoeJZE1VmHPVmcjqzBvU7kFFFnjtRDz6B6yMgLgP
         O4SddYcKe+CCfDZtcVRASAi4zehCMPTy9tTC95aYg2PdiOoHMtbbRKjCgWUYiyPFuP1s
         rjdA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUc1tEimsa0QuwEb3Muk/2VCQGOKwXX+AZ0J3hFxUBuuetPTxXW
	Jgn/O4pj569eNlIzW3+ia6m7It+B3e4Phv8I9XbQxGVJhnP/QLTvYRFxAw/90gCHQtGNR7NeXDF
	KBpIs2sIpHk8yYKg6cXKdgCULNVq2j4fEbeRRrAKNkPOTJ1kNt8wiZ90l07swygvG9DIh1J07Er
	VRl1B02xdusn3U9jcxX1PP/mvM0hXZvPnpMCbQMqDBc2b+mKKGZ6ectXUL/hg8RJR26ydRNWgwt
	umQOMNK+7dE+Qydy6OJjwksyeyPoBor4r76tka1OeLPA3BzgyJvjSe36S/SxPcpuBQInLSydiG8
	ggnQmVJrIeE3Isf8RyVajAI0Qxbs59565mItm699tkeokfWtCyTWjEOizF5ctEOlJXhWruBgWb0
	L
X-Received: by 2002:ac8:3928:: with SMTP id s37mr13211465qtb.246.1552011667486;
        Thu, 07 Mar 2019 18:21:07 -0800 (PST)
X-Received: by 2002:ac8:3928:: with SMTP id s37mr13211418qtb.246.1552011666724;
        Thu, 07 Mar 2019 18:21:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552011666; cv=none;
        d=google.com; s=arc-20160816;
        b=uSqX14JrkCYyEtHFU2nmPAodYrHrlyHpFtJ3u2cDglekUg3J5aZPKpCfuAgHhcbRIz
         WcSnImaQlAyRnTE5xEnCxjTiYgJyFXsnwm3GOvTP0ZUcbXRhwlD8e0ddqr1VfoffAgge
         Cqo+je+4XGWGe68RshLhrhOU8/DcsogPHMVcrwCsdq2UYEXDXOrMNFs+oHsN3TMweoje
         i48x+q3/G0mWNqqgz7GmZeYDcLLGBeMGSWXxiYOaM+786xjwZnyq5uKRq864RDUvLN+N
         vycozC8LEXoNtnm/zRPs+6eYyeMR/+DRaO8QdP1r8qS7V7mkdCy7UV2EFKsoZ8kvmBd1
         JJ9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=2TXa20qb/Eg4W3WSZnBQT88vOwNyfmVbxryiRAAOMZ0=;
        b=weaUstZ4cyI553T5LytmEZDFH0DHNFjE3pTHT/EIDSlXMLM7cPHT51h51PIhceqJOe
         Jq/DFB3J37F8ibnDXdqrbGTOtf9+A1OmE0JERmapW/a55+LdVo7g8dRhHsc3nqh/Wbvw
         4bAF/rL5LbDHPq8cWwNsW8/Wz103H7w66FvIte1aTFOYdwl3NkfcBfeDg9/0PCtqp3C1
         pTlWWcWMVRDISjw4H1xg0JglAkO/vqiwjO96K8Jk+D4hhhGynEU4R6EMZxDnJKHFqlZa
         0tkJguaHzrVf3r50Ldi49J1xj1DUEiCtl0Srig+Fo7EbVaHGDKDNW3v6X/Vfg3jMd9i7
         ID+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k27sor7232445qvc.44.2019.03.07.18.21.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 18:21:06 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzwmvqaJpBh6BkGPYK/AtjzjCuM+5N/KdCuho9+qlSH99IkjHAdDdmV+TJ2vuAvSfuxMvgJPA==
X-Received: by 2002:a0c:a8d4:: with SMTP id h20mr13474604qvc.46.1552011666383;
        Thu, 07 Mar 2019 18:21:06 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id q57sm3931129qtj.79.2019.03.07.18.21.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 18:21:05 -0800 (PST)
Date: Thu, 7 Mar 2019 21:21:03 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307211506-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307191720.GF3835@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
> > It's because of all these issues that I preferred just accessing
> > userspace memory and handling faults. Unfortunately there does not
> > appear to exist an API that whitelists a specific driver along the lines
> > of "I checked this code for speculative info leaks, don't add barriers
> > on data path please".
> 
> Maybe it would be better to explore adding such helper then remapping
> page into kernel address space ?

I explored it a bit (see e.g. thread around: "__get_user slower than
get_user") and I can tell you it's not trivial given the issue is around
security.  So in practice it does not seem fair to keep a significant
optimization out of kernel because *maybe* we can do it differently even
better :)

-- 
MST

