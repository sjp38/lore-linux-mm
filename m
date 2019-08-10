Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 784AAC433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 11:08:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AD232084C
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 11:08:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AD232084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C51806B0007; Sat, 10 Aug 2019 07:08:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDABD6B0008; Sat, 10 Aug 2019 07:08:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEFFC6B000A; Sat, 10 Aug 2019 07:08:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2526B0007
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 07:08:05 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id v11so5088618wrg.2
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 04:08:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/gjgu5WFnIUfb4QDD4jLVG7HzuwA2jqQre4tKbYILE4=;
        b=ugxebm+ZWTZK3KiL2nqb638AYZCSAHOwUIKaNtXiZ8gRklcxzVzJt33SNQbNvdFqit
         x8hzYHG8ZhomXYr/fMfplu69JIeegBz7S3o9NY9IhYWgR/zBQ0Yxw6zhZ6dcd64XhB6r
         bvAHEQl2zffu8wcfgVETk+3MdXA6XLxpVXFHip5c+J92tOQTvGlaoykZ0sZ6vZKdSGi1
         ybfiDEEp03z8uzRrpkhHZaw5n/OP66cP4LLpkNqtYTVBvPZqvdN8guXt11gZxBMn6PhS
         NT2qPDgRAqoT2uSuvaeK0LdDpTpOvz20k+JkTRTuLPLEa58BiAec1TLXmM1Y2o+w0ryz
         BTKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVpE40H/hyY7fYOfjujREQdK4x7ASQAtoxce7ozG10ZPnWf+O3g
	iQ2TT4fpPMEb+gzLO7FCRsS3DOmZf5XuurnURCtq4BxW4MvDoUefXYxzSO1jeYQSr/oquRTiEuY
	8V26ZqmgK+fRc3HtdL0By87b13B9w2lt+oIlK4iqm9UDgp0OcCFEuodpk9uaP4xzVUA==
X-Received: by 2002:a5d:6307:: with SMTP id i7mr16894572wru.144.1565435285121;
        Sat, 10 Aug 2019 04:08:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7PedfAPJWftGkPtm/lU4m5Bu4VmZ2/lJ4pWYbw15YRzalvAdKYEoVOh7dlhVFRFRelqUi
X-Received: by 2002:a5d:6307:: with SMTP id i7mr16894516wru.144.1565435284496;
        Sat, 10 Aug 2019 04:08:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565435284; cv=none;
        d=google.com; s=arc-20160816;
        b=pZLVc64XRzzQCFWN5fc1PRbFTbIejuMOrNvpUfnwSV8cHYPYxGeOp41mTWH4Sqgf6f
         MH8ClNaa9t0adDPwmmMH1nCgcVippF+b3rGUXceQRUVy594TGZXyPR0mWAHEzeVMCLfY
         0TmuPS7db/1vRNamQxVhLzypj1TlI3r6Dw1dVyK6vuG1IOkn9pjYx5QD4fQskdrIJd+8
         klIdzmD2S+jvl1XBI04N9ZNpZCySF3gacgki+oXWWs4TO5tpokUXvFxvAmMWUDwswpUX
         S8PKEbLveqIHAxArCaw8NiJGGfjuPqwruqI7xTrM0aNHXJjWLlVMo1uJGlYbZYxXH8rv
         84fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/gjgu5WFnIUfb4QDD4jLVG7HzuwA2jqQre4tKbYILE4=;
        b=UTiK0l7z+aYEaTai9EaO9vc3AJPRTESO3oyV6iKlA3A25iS88vYLFlIr17CNdYbbWd
         RTyVjp60BZrG/yPAbWBgMOX6jFm5JxOWuL1I3Ml8XPcN5T0eWPnO65yoWBE6Y59clnwb
         O2LrXKO6AzEg0e2gcPZUOV6maI7tNa6YfI4ye51N9UOdUjjO4kF6uig1eGG2TPTwJG4R
         fQwI1tjn+L3JBYGl043jbASMgNAJNk6J9ARf9N/x6W9Sfsc+m3WJNpaZ0LuwpQNEDj6i
         np3aN1oXBiOy5MOgNG5Vt+hblK/OovwhGH5U5gMf8+rH8naoSAPo+nXRHVZ9lsuI0ykF
         Fv9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n17si86625858wrj.202.2019.08.10.04.08.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 04:08:04 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 2D25368BFE; Sat, 10 Aug 2019 13:08:02 +0200 (CEST)
Date: Sat, 10 Aug 2019 13:08:01 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Bharata B Rao <bharata@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	nouveau@lists.freedesktop.org, dri-devel@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 6/9] nouveau: simplify nouveau_dmem_migrate_to_ram
Message-ID: <20190810110801.GA26349@lst.de>
References: <20190808153346.9061-1-hch@lst.de> <20190808153346.9061-7-hch@lst.de> <08112ecb-0984-9e32-a463-e731bc014747@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <08112ecb-0984-9e32-a463-e731bc014747@nvidia.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks, I've added the fixups for v3.

