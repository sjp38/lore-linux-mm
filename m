Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B86EC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:03:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 060062054F
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 07:03:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 060062054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E6036B0003; Tue, 25 Jun 2019 03:03:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 697608E0003; Tue, 25 Jun 2019 03:03:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 55E528E0002; Tue, 25 Jun 2019 03:03:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 230BF6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 03:03:07 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id a126so191664wma.2
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 00:03:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=mOyTZEpQNeXd39vhoGPPHyYzirk/YcajKPYQEJqEqS8xJrab7WLzJGRytEB3ZF8PgK
         axyGyCwdD7XGDLZtbXbb+2Y2QpEZKwgoYQ4MLYMQomaRBEBdnW4qX01vEb+wHbnOO1y3
         J89j+iYzg/hRCTUzLnw3pAa+lOE+DKrlMVkOqyypv4ohpiCRGJiFKO/7RvTMs4sFYapv
         FF4NnrCMVLBkfI7yu+2Rqk3N8opUMq4LLX29E5QVKAd9yb9paAM2dkGtOYfqRfw0ir5z
         UDg4Aiu2nqzEKsvsuzi9nNN3dKviqOCKJheE1yU5qVcQfLiSO0L/ppJn3Iy9mmoQvqKf
         /fcA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXopECoxf1sWJz8VUQZJ2TDizPmLXtbLR3BVf5hdAiDHAMqAWh2
	4DPA0VNgF4IwAwsy52rFofDz/NA7V3gMiSewoPgVsnrXuCPDhPZf/YxJRy9Nrom2v0qte/OJbUB
	g04ByN76pMduO6QDB1pibZDCIcyKDMZyrXq6xOaeimeC5GWkV6jup7N+sJ0ZKBfPQXg==
X-Received: by 2002:a5d:4b43:: with SMTP id w3mr26976223wrs.166.1561446186680;
        Tue, 25 Jun 2019 00:03:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpuw5VmShykWaMUDlQaMqELk+rAlAI7NfmB0xjhT1ywvkGvimFN2CFONn+H/SMDvdMVi59
X-Received: by 2002:a5d:4b43:: with SMTP id w3mr26976148wrs.166.1561446186054;
        Tue, 25 Jun 2019 00:03:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561446186; cv=none;
        d=google.com; s=arc-20160816;
        b=AJuoPyt3nttKbI1xG6G5xthYxA/V8biMWFt7WUIzwqx7xO+sfhgX6LP5FdpoYF7cri
         d7UrrEFQ41vgQ1IJd8Av3WspBeNnVh/DfdWBSdpJkKm6Q43ccCE0BkjGo+bm7whQB9XP
         cywGh3fN4KHgVuQ4bShN0RWK7AV7/UdmY2VY8+puSiSCvM1+jBdtytcnMggOdh9uXpOE
         M3Wun0tkx/LDEnnIYjitdk0JykfRWuj1rTU4R7zyHHbderSwliX+jW9FqINSdwc9B7wP
         dgUqEleKXWjpmVpwrn/1hRjJCgWnGJgjbp/J2qSNF7s+5Z/kqedu+Y7w9FFEnykBpZth
         Xx/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l2WBiCb5duYJRA9nKpihqrJOH1Qjg6utSrFiu8qAdtc=;
        b=hhT6tcGRU0BeG9p272LqiLf9yXqux6evZYloTQGYxVu6VP0SiDDqvbmr0e0sxSatL/
         QJahjPVLqgkud9Tuee9I750Mn8HLBkPeV6dgKUlO+DTHp0YWkNQXDAb3l7xT78mPsVvy
         WZuDFvk7TEU5qQzaY/kM9n5emZXrHENZ+c0BmWyRaX5TQchgruGJS0S2YvKQbSnk0oGp
         hV/GJ7s7RsJuh9oYyRBSrsYKTuyQqdGp8eoMcoBQfwzi/BtpjdP8NltE+PQEt9KRwJ7c
         Jpg63iFT4LUwbcCjf7fcNHlOLfzhdZvgPKzkeYb3c7TI0LUASPXp5879Kwp3LvUIV+1H
         Ki9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id b6si11005036wrn.368.2019.06.25.00.03.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 00:03:05 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 15DDF68B02; Tue, 25 Jun 2019 09:02:34 +0200 (CEST)
Date: Tue, 25 Jun 2019 09:02:34 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, Felix.Kuehling@amd.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	Ben Skeggs <bskeggs@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Philip Yang <Philip.Yang@amd.com>, Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH v4 hmm 04/12] mm/hmm: Simplify hmm_get_or_create and
 make it reliable
Message-ID: <20190625070234.GA30123@lst.de>
References: <20190624210110.5098-1-jgg@ziepe.ca> <20190624210110.5098-5-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190624210110.5098-5-jgg@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

