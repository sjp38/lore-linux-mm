Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6B60C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:14:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7158F2087F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:14:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7158F2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E58C98E0002; Tue, 29 Jan 2019 11:14:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E09828E0001; Tue, 29 Jan 2019 11:14:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF7508E0002; Tue, 29 Jan 2019 11:14:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B56C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:14:13 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id w4so8065479wrt.21
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:14:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=wn3jTseADLeZgdrhEVbdli071xyFzz58Lz51sRtQp+w=;
        b=NUPC2d1H9egL4oSCb0jDO+NnSRc5LSoi3ydoN5xF29hpdEgUIY6QJZVLJ6LCYhCNFZ
         rmHnM18+uUo+b3J+lAADwSzFHk/7CnWQ3mKrB6cbjKFgVmVKcoJxOWmpRKOuVRra8X3X
         UkfPkeW13sNMV3j3WlEp03GR3+iXC/OaDIXPYMoJYHsSEDYeEAcWn7RhqqVYbUgn37jr
         G2LKejjA6qELf7mO+LCirW15EPczc7ESCwvDsDm8pUVy+vKVVJaF4zqa6KZJ4gPhdSyB
         57r2jvB/x1U9CV6trhWZfwVAguLIE90uvf+acXFonn+UDWF+xF+hAo3NoGqdw3uE4yrH
         yArg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukfNl2VWgFo04MEEYdP5sscqI60+EKD0clCPcyMHLWvSyXCmaApg
	blrGx+JBvTlCD6ykQx/f0sbm1ieljeq8DjhpTi7KO6FHDMUYMLTwFSFLXSe2hXh2B7Cq3zAftqF
	aS63qRJ7vbZXuA67svlyffITOJoCkQflxStWRESeMAQ2oRTxmRZLP22EjEhNo8PdeEA==
X-Received: by 2002:a1c:2804:: with SMTP id o4mr22924458wmo.150.1548778453081;
        Tue, 29 Jan 2019 08:14:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4vtS6ckXRQ2A7y9ZePAQPx4OInNnwvBxWjj7XNl4URhstLw+qaFaHMCwLZaDKnxu9kcRcX
X-Received: by 2002:a1c:2804:: with SMTP id o4mr22924405wmo.150.1548778452197;
        Tue, 29 Jan 2019 08:14:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548778452; cv=none;
        d=google.com; s=arc-20160816;
        b=oaIF+40CcWE4xLoHxInvOadQVgivpOy4kDeCfAN3jLZTYFQBb9W73wyl3985EbixJZ
         75tuWfQbRL0+AnvEZVHKlm5AjyuE2mO7pLiOAgJzfwgrRMSxQ9BHTXhI0MAqL4wLR0KF
         /dLMFz4rwWvwsnEQUcLZnnvP+fv9FxRBAyuq9z22ALRc1Fv97oOsD5aFdd1qnwODCism
         APTSVGFwBWlU9ACuwr/GsYxBO4RSDfbUjsCQN9SIKAOLLAf0cB7WUDc8i1EEBY5z5k4Q
         W9urvU25pxnjYTxxcqwwVur+Q+ntp74yxKACEoE+Iwewq3fraRBxrHDpUsSBHZxt2XqZ
         EkyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=wn3jTseADLeZgdrhEVbdli071xyFzz58Lz51sRtQp+w=;
        b=CZu6zXzNWIJ9Rv02pOzWeP5u3+buKybmaQ7WHYL1C69O0vn/silHQQJVkCJG2j6j8c
         /JeGJLKOVrwcCXxj2mPUs8MYS31fsO1n/ayegStXhgKo5v7X37ckqMARXC7yTMRsR38A
         Pef2GsX4xwox7K5e6lemIb9GMVbCRKz2c9uhFHeGgKvD0OIolF6bVQ4uPT7uSIj+GS/Z
         aAZUF4QUxHSn5ZDmcbhri88kI7ocYe6Z3SBzPKmxOZTzBw7Hn0qX3/ZH04BLJpOa3aWQ
         5D3lMPr8uWAG27Si6ORk8F+4PiQU7nyiQ9O9AlbLh6yaza5pKiTY7dBxFVUiqZuGFHSp
         LlEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id r12si81166054wru.318.2019.01.29.08.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:14:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 575C068CEC; Tue, 29 Jan 2019 17:14:11 +0100 (CET)
Date: Tue, 29 Jan 2019 17:14:11 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190129161411.GA14022@lst.de>
References: <20190119130222.GA24346@lst.de> <20190119140452.GA25198@lst.de> <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de> <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de> <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de> <20190128162256.GA11737@lst.de> <D64B1ED5-46F9-43CF-9B21-FABB2807289B@xenosoft.de> <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6f2d6bc9-696b-2cb1-8a4e-df3da2bd6c0a@xenosoft.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 04:03:32PM +0100, Christian Zigotzky wrote:
> Hi Christoph,
>
> I compiled kernels for the X5000 and X1000 from your new branch 
> 'powerpc-dma.6-debug.2' today. The kernels boot and the P.A. Semi Ethernet 
> works!

Thanks for testing!  I'll prepare a new series that adds the other
patches on top of this one.

