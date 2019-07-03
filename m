Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54082C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:01:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EA5E2184C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:01:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UR+mB33w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EA5E2184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86EAB8E0010; Wed,  3 Jul 2019 14:01:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 820808E0001; Wed,  3 Jul 2019 14:01:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70E558E0010; Wed,  3 Jul 2019 14:01:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB4B8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:01:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id k125so4040212qkc.12
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:01:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=a2vka/akssy/859dgmuGdTYFT4YH52SMxVHx2PN2EUA=;
        b=dSdB/z0u6Yny1Ag9mjHT4IExz39FNV/oCea8m3JNKOXqAPrd/3BqZjwIufs6weevvc
         CgfJvJLOATze1ZFKeXi9Xo+Ek9JauEpliMT64AECs0F6MyvGlEZtYR5lPndvMFQEhjWB
         pQuQW4hu1Zdi+2vMhzrdsDCUYO5wWiU+kNIsyih6OC6nFC/souHsIHklJkeGdOupZDiv
         0GxO41i+aK/8LFJsW47vFc5XrUPqwP1OpcsoTUZ0ydRnmvnjGEmftd8VVARCiPZ5VlnN
         VoIs5eKfT+6HFP/zuaI1PWxa9ZNmKl3lIXol6yTx6uIZZijCakX4R+0g23BNwhwIMYLP
         SY9Q==
X-Gm-Message-State: APjAAAUJEAjRCiCh09K73SmniQ7/WM0UZNQZaWnTaVhkZnOmJCOMdweF
	UswDB+UYWmV5hp7O4ceyf53eCvX4oNVYsL/D6zgxg06IHm6EFT1pc3JKFBVP1HBavHr2s9FaqxI
	2jWgMb6zlqV4BVHCzVbgM8heDmcz6/5yek3W3VG4eu8Ai+a2YhoJIcX5lzl3mYPjvkQ==
X-Received: by 2002:a37:9a97:: with SMTP id c145mr32683467qke.309.1562176887116;
        Wed, 03 Jul 2019 11:01:27 -0700 (PDT)
X-Received: by 2002:a37:9a97:: with SMTP id c145mr32683415qke.309.1562176886556;
        Wed, 03 Jul 2019 11:01:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562176886; cv=none;
        d=google.com; s=arc-20160816;
        b=jX3shmx3yYx19mR8xFEVA7+o+yhlxSQH5HEXXL9VC/HsUmZHyvr9fAIvOI6C3yyBDG
         jTkwv6e5WMy85Rabsh5NaL1AZDICHOIiFznIrf9nhKk6jDuhtPxpKDTes4lfw8jtQlOl
         6SOWcKwjSEu/UsdCKmJHH/18rByUICZU5Xq9lG/5Op4f7KyVSo2yFzJFiqai0vgz6a0I
         WxI/lT1wUstivfeZ1g0fVSOsyLqQf3zSL4Ptm07epvjZ/0JsrVQ9CJwuS4fk+cLll11w
         mmbSWIlD/564R/alik6X24b2KgUIrHBnvFn4hAHBADo+PqngzhmLcrbgVopJbdT0dY3+
         V3Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=a2vka/akssy/859dgmuGdTYFT4YH52SMxVHx2PN2EUA=;
        b=nn0K/8eDLhFYvYLpiSvFLYfPLfcH2S37Q7dOyM9ttkAlD87vnUVqHX/aZz83aq5R7B
         7iJGPiTd1wY60E8xpihUz3GRPITuflensPNuxcHqVylXSyG78SAO6HvPx+O6pttaC47y
         9lTz+QIjhXsLaWNFZFDMexu6DjJxoJDz04NTQQqp4UDhVwDsb/0L26+7k3Ld4IV/rpG6
         jr36hGeJ/AQa/TlTOic3EOY0Awj4IdBhIRmDN88bBMRzpfyJ+E4fm5S151B0lPBkbqF3
         Jn2DceYkdH64YWhwUyibLMJ3a9ZPoAhmDYC9qsj2z5jL+EckGODlKKMa2ZYBh2DbHyck
         dytg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UR+mB33w;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m126sor1849688qkb.189.2019.07.03.11.01.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 11:01:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=UR+mB33w;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=a2vka/akssy/859dgmuGdTYFT4YH52SMxVHx2PN2EUA=;
        b=UR+mB33wfBhu3cMDn/7EBIfgFaGZRuvY/6J1fd9PhMgOfBQW4lCtf4aW4cWrAUOg/V
         ysDxZJU9vC+aEmT4cwhxTIl4TYXWNEvXLnwzfoSFoTPuhqs/gUxKo54FOzEU1qF6lBPO
         BDzC9RkbmXZgFl5C89Dr/DavME/J23LtilDnr6BOfCLfGcmh3h3ZqRvCwPxs52Z9/ShV
         88aK4465TTIaWrpxAOzvxt4Awc0wM1VxGtTmtNuDdYn6htswBnMWDqrfqYcoFAAtYDKN
         PK+3yzvEgZr3lVoSgy+/yjpH/TVAkGrizrHi9TWzWfIHt86MDzHjD59dYGp18SQRc4c1
         cphA==
X-Google-Smtp-Source: APXvYqydaJsLmmJTIUtSU+kahyTjsnRgAp4YEYaGKvpkMDRvv9xpp1xwyaxLhy2xlOb2NB+ML08lUQ==
X-Received: by 2002:a37:a413:: with SMTP id n19mr30343855qke.98.1562176886317;
        Wed, 03 Jul 2019 11:01:26 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id u19sm1310165qka.35.2019.07.03.11.01.25
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jul 2019 11:01:25 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hijZN-0006oc-AR; Wed, 03 Jul 2019 15:01:25 -0300
Date: Wed, 3 Jul 2019 15:01:25 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 22/22] mm: remove the legacy hmm_pfn_* APIs
Message-ID: <20190703180125.GA18673@ziepe.ca>
References: <20190701062020.19239-1-hch@lst.de>
 <20190701062020.19239-23-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701062020.19239-23-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 08:20:20AM +0200, Christoph Hellwig wrote:
> Switch the one remaining user in nouveau over to its replacement,
> and remove all the wrappers.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  drivers/gpu/drm/nouveau/nouveau_dmem.c |  2 +-
>  include/linux/hmm.h                    | 36 --------------------------
>  2 files changed, 1 insertion(+), 37 deletions(-)

Christoph, I guess you didn't mean to send this branch to the mailing
list?

In any event some of these, like this one, look obvious and I could
still grab a few for hmm.git.

Let me know what you'd like please

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Thanks,
Jason

