Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34E0EC31E5C
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:10:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3DA9208C4
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:10:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3DA9208C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A446C8E0005; Mon, 17 Jun 2019 16:10:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1B068E0001; Mon, 17 Jun 2019 16:10:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 958358E0005; Mon, 17 Jun 2019 16:10:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 620698E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:10:28 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id 21so116539wmj.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:10:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=jlgbPlQhWskt5EntWDdHkbSaj7p+HA0ZHZ/qjm9Zas0=;
        b=sPm4ge/+AntiyPpSwehe9G6chV2F4hQPRktjkXAGpokeElEzjUEmHhUgUvxbnhbjHm
         iXv6VO2wejwmURtelFt7vht9oRkiStlWLoSS4sB/tB4xQ3XufUjX9v64SLAQ/onbsA9/
         hxrAO6sZKxg5S6Q32NrCmwidwGR+1wHtxEhcRDnKrKZ7s4U5cml5RuixMq0d0Sd/9fhb
         40Og6boa5Niumx7lJkNXG3Wr/QkBXwceDY2EVZHabNccYtWp+PD5lLVGLqvDgbHdnpRI
         EQIPDct9B1WUNCFbZTQevnrFLwjZTfOYJuWFFUeOA4RG4uhAdoL5zATLDBJAliRX/fOW
         3P6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUyEKGgx0bZzPnVpXjggMsI+HYUgEHTcWPjL2hlWhSk29ZARpd7
	z2Gr4kEH7nR0FkXj1Qy8rj3uyWOU4SWGioyGkgAsONCCUQ+W6/dus+1FdQ5NMOpFEZTHeE4sKeX
	yxjRgw4WW1pbobyF8pLYo7oJ03Pw/B9WwCws1WhbFz77Dap2S+/nNfGB4WoQg9nG0Lg==
X-Received: by 2002:a1c:452:: with SMTP id 79mr242419wme.149.1560802227919;
        Mon, 17 Jun 2019 13:10:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrN9gE5nZc/gD2IzBUCaHn6R9ppH++cqSSTbGhGSL7KB+ZZrLQJi1JTvely5U1csYK9+RG
X-Received: by 2002:a1c:452:: with SMTP id 79mr242393wme.149.1560802227221;
        Mon, 17 Jun 2019 13:10:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560802227; cv=none;
        d=google.com; s=arc-20160816;
        b=UF5F0dmyNc1oWZPcUqIDmXKEVmpNwxxOLBa3wCqotOUgCCtKqNKKIRRGnvu2P8n5GS
         D6wOnPue3ergX1np5WyBVLefQWqHmJpatacqR/MfBKe/5Gypdb9NghceoCFasVJX8Rkc
         CIjDCRa6gxlbVisg3xCfQulzs0pyb8bRvH10m9P0jWbxmimqJu5Txa8bIypc5O/dTKxH
         zgXYAUxA1VTfFGJhmg0Q4tUuwG5pnitocYuJs1TnIQRLkg6/Nz63ms8YL+iJiqAhAs8X
         33572GflAvHyCp2V0TORLYu+RoE15q1FD4OcieXwyvop6JwzubWmDABhDXQ5YOMW5OV5
         2J9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=jlgbPlQhWskt5EntWDdHkbSaj7p+HA0ZHZ/qjm9Zas0=;
        b=W++G3OgD3py2Z82UOaULTnuc10g1Yl9bEoB15kxbNgjNHZionInH0H14bfx/JUXKr+
         SaCagGw3SAzvt/1qFe40FNRsSwOnFo4xgkYrgCSn5YDwLl9HOb+3kzyzoM/ncR5/PkbK
         uMBXVjKv5jNuhnxfZ9Y7zGEDhqxf6IPQbwg7NZnhWvZrXRhZ61Bemh3vpXR8Nf84yvr8
         NfW6ILLbOj8VpsuSX43CoSniKTXFfkY8OzVOrYHObGeABcgp+sPZI80a7zc2FWfZ75ow
         XMs56p2HF8u55LxEzTbuPJLikqC5H9XPCk6AHR8Ge9X5H7mDLD0pObVulgtkmoRe/Mqs
         3pXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s22si200053wmj.71.2019.06.17.13.10.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 13:10:27 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 0673468B02; Mon, 17 Jun 2019 22:09:58 +0200 (CEST)
Date: Mon, 17 Jun 2019 22:09:57 +0200
From: Christoph Hellwig <hch@lst.de>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 08/25] memremap: move dev_pagemap callbacks into a
 separate structure
Message-ID: <20190617200957.GA20645@lst.de>
References: <20190617122733.22432-1-hch@lst.de> <20190617122733.22432-9-hch@lst.de> <d68c5e4c-b2de-95c3-0b75-1f2391b25a34@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d68c5e4c-b2de-95c3-0b75-1f2391b25a34@deltatee.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 02:08:14PM -0600, Logan Gunthorpe wrote:
> I just noticed this is missing a line to set pgmap->ops to
> pci_p2pdma_pagemap_ops. I must have gotten confused by the other users
> in my original review. Though I'm not sure how this compiles as the new
> struct is static and unused. However, it is rendered moot in Patch 16
> when this is all removed.

It probably was there in the original and got lost in the merge conflicts
from the rebase.  I should have dropped all the reviewed-bys for patches
with non-trivial merge resolution, sorry.

