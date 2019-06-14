Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2855C31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:29:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C96120850
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 06:29:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C96120850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15FC88E0003; Fri, 14 Jun 2019 02:29:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 110B18E0002; Fri, 14 Jun 2019 02:29:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 025438E0003; Fri, 14 Jun 2019 02:29:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id BF8E28E0002
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 02:29:12 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id z202so205909wmc.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:29:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8kDfS5Doe1pWvmyk1D5vMRHgPf8MkA2/rgXfQG9TaX0=;
        b=bCfqNiWlnL6aRAKw3qiWXpFzWiyPZob3lkcm/zOBX+FHubm84zMgFaps7zaeEjRUS9
         l8bm3YCc7RxAUOJjtzS+dPTO72c3Y5qFTJvmzp3Z/W+6D/LymePMVoNDg2XOECucy/ov
         GX3ivJvxYDoAL2WWks7uHOPK6/CyZ2hShJmrEFTV+LLALA3LoUwy+TCdep17Oi39E5Ch
         W0VJbtTXVuybGM9LXC3kJloc1xvAzmW7ldroGy2jjhTcLjWobnwmDGAb4sQxMgl+9QO2
         gDCo/yMhKNUrVDJMduYhHzh4Jp4PowAQCVsTqSnbArOXc/lCCjs0twzX5LS+iUQi8BhV
         sZ4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWD9JSAQcbtfSC9anTBKh/GDjOeSxd52sYzoFZIIJRDZLEmaX+v
	qCK3LhbbmIxLLLjmurVpBchovBWlEUsJzOg0PdxU+ozeFDBrC4uQmYOLUmEYeqC1Q1IzYRB7ZkZ
	ThC2KvouxB1eiajcO9IERUJfvH1ldP6HDw+fER1EzfgtAxdV3TIY3JZ3QBwBhPsxvCg==
X-Received: by 2002:a1c:f319:: with SMTP id q25mr6139595wmq.129.1560493752357;
        Thu, 13 Jun 2019 23:29:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFGu1JAKpgD2WvjKjZgHtnNvC1ZzbCXyZqebP1cJpWtkzP7l6Hrg50pzFYofkg6BEuXicI
X-Received: by 2002:a1c:f319:: with SMTP id q25mr6139555wmq.129.1560493751689;
        Thu, 13 Jun 2019 23:29:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560493751; cv=none;
        d=google.com; s=arc-20160816;
        b=VmPDxPdaV5Ni1cGpI2ACHSgQR7n8E8A47vod2SB9bHTOiPDXx+XpTiX5FPvP6Z/FlO
         q6B4ZjPlzVk6kU8/kySnZhuW7BXP3bPhyjfy4UK+FJOKoSkngXL8xpbRIh52dPoCo8av
         NXfsqDX9U1nR5uIWqDZi1qejS6AeZj7Onn28bvfOXySCn1c+C7rwsNKRH8lJblgofByw
         4ZimuQ7mvy7hNX1zA0egWhOccgAKOnLND6710+Bk16TO75Y1361EdPJFxYpA5SRBO0JF
         DVraIz8Bgwxz/M4oEfm/UVMef4SHK3TLNxFSozeXQK0sf4vi6bAfUeBnhSqzMdEAA0Cn
         e2uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8kDfS5Doe1pWvmyk1D5vMRHgPf8MkA2/rgXfQG9TaX0=;
        b=HyEBjpVsbDmLvk3rPxMytJ/OEgCbuuEn3UH+0Vcv+J/kHvDB9Rc8jftETGsGkg1IeH
         sfhqTN0pgVMqIBbjWbRuhjvzvITL7ecWJ3UNe16/njMhGb7tAxz00ccJ4kKNDmGNW2/A
         hBKTqyl9BufajBX3KTEkUMfMeHYnm5MqrGBsybf38SzF096anmuhJsUkwjhldsoFRgew
         vMrNUpTnclHP7MGlBA/Xwfqrndx3XyO6qNQTOS46rTthfjZFB19OQFbkPbzDSfCMdfoA
         SRfxULiy5vT6/Jpk/ValDuWLHHIhaPL8bzGyGlUY/qoEJA5O9Qu5kY4bjetu5agwcBxY
         FElQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id d5si1275438wmb.133.2019.06.13.23.29.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 23:29:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 2985E68B02; Fri, 14 Jun 2019 08:28:44 +0200 (CEST)
Date: Fri, 14 Jun 2019 08:28:43 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 09/22] memremap: lift the devmap_enable manipulation
 into devm_memremap_pages
Message-ID: <20190614062843.GI7246@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-10-hch@lst.de> <20190613193427.GU22062@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613193427.GU22062@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 07:34:31PM +0000, Jason Gunthorpe wrote:
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Really? :)

