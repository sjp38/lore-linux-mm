Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19553C31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:09:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9DEF21537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:08:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9DEF21537
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 556B16B0007; Fri, 14 Jun 2019 11:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 508506B0008; Fri, 14 Jun 2019 11:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F7936B000A; Fri, 14 Jun 2019 11:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4F2C6B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:08:58 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e8so1157967wrw.15
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:08:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MeEVKxhQ2xPuD2dC1n4x+JdGo3cEeGgwc7wwivXdsX4=;
        b=sTZAjozHPhZPN53aQbS16pAVoaipSBLJrRME9kBm0a4I/Ve5qFLxYdLJGf8j7+LTAI
         3sBPuuZJNzns8J7mzpS4InGV/tk7yE0ZDaYqJ8MVoriKMPi7ruoSg3NFmN4MtYR9sLRr
         H6v3jNvMRHX797WruVRs+DJnTxudCcxaImTZxHNpSMZiXBxqfl/pEidgcF/lCj1ACSZm
         6zuYos5Earb8dB97CEXhmxEAPR1sUYCm/HLXvQthiBFPzhC8BTbljleaQzjg+tQd7biF
         FZSMlrTMOo+yMmLgqrlg2O33dS1ees7jelTI6YM96xIBo3qXqLvv4Wi+fzMqRfM+nDrb
         On8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWt71E2IWh4M1brtNixptRAnId2+MlCzZ5AMQTxNy3QP3k1Y6fy
	APX+/3j/LHN5xr0lIFa1/MBzTYdpYjYRtDgSwGIdkxAmxqxoPgcODScZfK3p/r3y7yzvqHAbD8T
	kHO9N0ngFAEZ8Q4sU/yu2xmyVTJ6sUkvtMFJabR5F8bJLZPvurwxEk1tTYC+BO5cm6w==
X-Received: by 2002:adf:814d:: with SMTP id 71mr16285937wrm.50.1560524938463;
        Fri, 14 Jun 2019 08:08:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIUbBaPgN7zyMmzL4ySLzdbrzDwdhaajZBhS+kFjmXkZe37/P8vI+gM9yzeo3+uwyWtBKS
X-Received: by 2002:adf:814d:: with SMTP id 71mr16285891wrm.50.1560524937740;
        Fri, 14 Jun 2019 08:08:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560524937; cv=none;
        d=google.com; s=arc-20160816;
        b=cXjXLf4WCtOxjW8mk9eJehmf8916Ww5LpTaZFeBfBqWZrdyfPyqgCgvb0uP6NtnjCw
         lrOveQx4oVDzua1vg4oTOMiIOcnxZ84fsX3ex+ss2Znl4c3NnvM8McjL/+0poGD//Xd8
         RX5cssZDrqI3KOp0lH/TCfUwDMQ1Kj10DkCpXU9yt5ZM7NyKLOcFMJq34njZFX2FpsYT
         Nan13RdR3m+SqjOULn6l9UPj24Wsvjw9ri6/ktjSvcJC1Zwxl+86xK7i0gLJNHxwDn32
         QnsCmLxLGnC1uNb7lsEIdVG+4uX6icjEneQ4ECUpV9ZmUW4SY86CfWaSGuCi77Bd5Sh3
         n48A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MeEVKxhQ2xPuD2dC1n4x+JdGo3cEeGgwc7wwivXdsX4=;
        b=SeyPpDkS27so8F3GrrQhswotGBTIumAS/cfcN3XWWC9Xu58mO2PgibtwwdyY+Ln5mR
         DmigzxwhN3Bh2bom4kGiQJWKezlqI6bEzaaRaDoNV/djf13mciUHkayYW3cgq+im1MpI
         12815vynXiuDFwPWj5AVFI0UEmxluKps1a0F4jc7U0YBBLdwBzvucDD/2Dtzg+hkwYMY
         ldQGJTcByO30VND6Y93KlpStUf/7ce3xcdbI5JvElbtKJi90BYBtCnGVwxz+AMauXuap
         x7+1KxH4/HAVGMh4u7Qx2WWxSbDftZjD8wnk2xHfaVlaiMvPQR16Aqt+U7KE6rhQllrb
         +GDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d10si2555450wrj.24.2019.06.14.08.08.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 08:08:57 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id EDC7268B05; Fri, 14 Jun 2019 17:08:27 +0200 (CEST)
Date: Fri, 14 Jun 2019 17:08:27 +0200
From: 'Christoph Hellwig' <hch@lst.de>
To: Robin Murphy <robin.murphy@arm.com>
Cc: 'Christoph Hellwig' <hch@lst.de>,
	David Laight <David.Laight@ACULAB.COM>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	David Airlie <airlied@linux.ie>,
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
	Intel Linux Wireless <linuxwifi@intel.com>,
	"intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Sean Paul <sean@poorly.run>,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
	Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
Message-ID: <20190614150827.GA9460@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190614134726.3827-17-hch@lst.de> <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com> <20190614145001.GB9088@lst.de> <4113cd5f-5c13-e9c7-bc5e-dcf0b60e7054@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4113cd5f-5c13-e9c7-bc5e-dcf0b60e7054@arm.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 04:05:33PM +0100, Robin Murphy wrote:
> That said, I don't believe this particular patch should make any 
> appreciable difference - alloc_pages_exact() is still going to give back 
> the same base address as the rounded up over-allocation would, and 
> PAGE_ALIGN()ing the size passed to get_order() already seemed to be 
> pointless.

True, we actually do get the right alignment just about anywhere.
Not 100% sure about the various static pool implementations, but we
can make sure if any didn't we'll do that right thing once those
get consolidated.

