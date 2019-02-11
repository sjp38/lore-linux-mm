Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35580C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:38:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C947D2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 07:38:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C947D2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E5908E00CE; Mon, 11 Feb 2019 02:38:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 592498E00C4; Mon, 11 Feb 2019 02:38:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45A4E8E00CE; Mon, 11 Feb 2019 02:38:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07BB98E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 02:38:06 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id o16so6316783wmh.6
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 23:38:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=u7X1iKW9jgsiowRxH0qwFhP2repuv3qYvA0695SjbEE=;
        b=t26sMs2kv0PfeIz/PnyJTMtu5rSBce2uANjJkR3wO4j4eevH2n0ZacfZe6xI3iIu06
         ESQ/nlfZxcbVWXlLBUb7ic4xO9WmZMAeXEj0rFVmA2ojlpkUj9iteNpNNOCaWiULRPvr
         XfQDm5PHOkLtFjS4QnMgvhel+OBfiMKSJZyud5LCDxJYsJyIOwPM4RX1XmsYRAy5Mf0R
         fOSgx9sDBneGTeyKJIZwqTP+V7Uf18jLfGcJd8gxN4QuZiTRpu/LaQYV/2XVC4tZgFKM
         lTx8nRLnfKLdSh2EVhWnVuFXSxSblR+04xbkUl0SHVpJiq+sXkz33JY2o5CZTzUtp9C3
         WHXg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYvl/gHjyWSmmQle/OWLYkKlSWXI3fx8e/Q7lpUVIbhLpYqRnfa
	YwPr7OMydEjb6bc++5ew/6o4LjSmw5T8qQ5nXY9WCO4iT+MtJWHqZa4+VQdhxzn80O3RjKnW5RC
	ZUktoX+s+0YzLnro6t5RADncSxYgVEX0o2M89I7G0brH/cV98t2i/uXpHdeX49eGe3A==
X-Received: by 2002:adf:fb0d:: with SMTP id c13mr10026126wrr.285.1549870685608;
        Sun, 10 Feb 2019 23:38:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYNMK16HFZE5oVh1PfLXmLhGAWkTy8X0+soNG216n9B/0hBwbHDaGeci4C77BZ07WwO9nWG
X-Received: by 2002:adf:fb0d:: with SMTP id c13mr10026075wrr.285.1549870684842;
        Sun, 10 Feb 2019 23:38:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549870684; cv=none;
        d=google.com; s=arc-20160816;
        b=u9GGztIOSXlpZoPsit/WLcvLwOxN7V4HLCNWzzg0w8ZzW25rWvaGe5nyI3D6wkNXve
         RMz/HfrRniblnyWkxMal2Buepe6vEARwZFbVrEdkwm4W1MNGT5mUzd2UOH+XeWKQPSMy
         vkeq5zieXA2GgI8zcVIEGLGHcyR6RqD6HDeuQccIS90ktx58KRjXAWZ0hGKFFJeqlgx4
         7Jj4Xjru0R7ShsCet+Sotb6V1m2YCYFthMToG0775ze8bKTEMRZMFirv18rCkMsATUjT
         SlcVdX9s2S1S95sXIgOH2iTUhYf8wlrEU1M2jjkGDjgHSEP1Cmn98ZX3thcuH9b+UZiZ
         IefA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=u7X1iKW9jgsiowRxH0qwFhP2repuv3qYvA0695SjbEE=;
        b=BGTm4tirlf8KhTLIt/RuVV2iARNTMlbQx7iCK0WlYe4egUM1q4t4/v19ONe1Wa0Knm
         uC4DYfcSWkTUlWBsELMN5dUf7VdTqVoWle/9wkLGIrtdyDmWNBhJsGElsfNsR0ZoLtLf
         EEgedLhpfZRb4BPtiPpWeG5i0mmWSHKo/KAzmwGIqjPScPD078NVV2xtAhEHfXAVFusI
         9PhZfwpiKE7xhdltLpfPzqmf8vEZq9eZmXOcV+nFhnCnL1Ulc952a2B/EeTeITajAlg7
         G2xwiMQZDvvx5HTUVT9KdQD/mXW+GjqV03h37mV0VqAY1E/pm4LXt8vIm4PW+8DXPPbz
         Gvwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m16si6590720wrv.419.2019.02.10.23.38.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 23:38:04 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 4E7517F11E; Mon, 11 Feb 2019 08:38:04 +0100 (CET)
Date: Mon, 11 Feb 2019 08:38:04 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190211073804.GA15841@lst.de>
References: <20190204075616.GA5408@lst.de> <ffbf56ae-c259-47b5-9deb-7fb21fead254@xenosoft.de> <20190204123852.GA10428@lst.de> <b1c0161f-4211-03af-022d-0db7237516e9@xenosoft.de> <20190206151505.GA31065@lst.de> <20190206151655.GA31172@lst.de> <61EC67B1-12EF-42B6-B69B-B59F9E4FC474@xenosoft.de> <7c1f208b-6909-3b0a-f9f9-38ff1ac3d617@xenosoft.de> <20190208091818.GA23491@lst.de> <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e7137db-e600-0d20-6fb2-6d0f9739aca3@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 10, 2019 at 01:00:20PM +0100, Christian Zigotzky wrote:
> I tested the whole series today. The kernels boot and the P.A. Semi 
> Ethernet works! :-) Thanks a lot!
>
> I also tested it in a virtual e5500 QEMU machine today. Unfortunately the 
> kernel crashes.

This looks like a patch I fixed in mainline a while ago, but which
the powerpc tree didn't have yet.

I've cherry picked this commit
("swiotlb: clear io_tlb_start and io_tlb_end in swiotlb_exit")

and added it to the powerpc-dma.6 tree, please retry with that one.

