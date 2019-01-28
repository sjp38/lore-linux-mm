Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D18E1C282CF
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:22:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EC9D2171F
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 16:22:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EC9D2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 037A48E0007; Mon, 28 Jan 2019 11:22:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F28DF8E0001; Mon, 28 Jan 2019 11:22:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E41348E0007; Mon, 28 Jan 2019 11:22:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A1B3B8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 11:22:58 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id 129so4025498wmy.7
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 08:22:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gw3F6//qpgy8BIP5lrC0jqrOUsmk1iRbGI4X92QxuSU=;
        b=Y3Mq1daBnNDNW6W8vDfF8W7kQMhUcUNujQ8rO34ju1PQfzyuAYapw0d5JuQ+xCIwMS
         tk1TXsZWwPpqZs/2499HS3vV76036DM/d0oCjHgUgFvFmOxUFCnx3iyefQA+UZDCF7U6
         XKA2K9wn1gI6sykndHRuYkF4QTfQ8In8klR2/ccWRkbdaaqYCW2se3zEmjhSWtgJ/16t
         ZTdx5G0siL7rpoVWBNykKK5oXMTS5LmvSvkcvkVe1qGqAcNbGCRc6j+xlhVQ5quyDirN
         l5Plal3OuGK7oMPnHUSvmt6dbn+gIrRIljG8AtewpTFiMv58ITRTun0UMNyKv298QvL6
         GSOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukdgCGvt5mq1/b3sS8Art90V9eJO7CUMLBuvGzM2KQD/QayZ01RR
	Tl3Ghhjz87uygtEtzKzHSJVs+MQJOli7MEcXSF6HaA9EftraY1dVyIsvOpBIa/3JNNMgaGz9IbX
	MqjNAFYYiTEAzlPvJSbsZ0AHfij0Hq3H766ursxKPyBrsWW4Pn/i6znPxVACVGdjbLw==
X-Received: by 2002:adf:b201:: with SMTP id u1mr22104120wra.165.1548692578204;
        Mon, 28 Jan 2019 08:22:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5VSSGr6AKOPLd4bu0r2qKIC+WznrfHoJFwKLxC+zG3M4RgFDkfIHsaStOG33WpJMvp4q1t
X-Received: by 2002:adf:b201:: with SMTP id u1mr22104078wra.165.1548692577400;
        Mon, 28 Jan 2019 08:22:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548692577; cv=none;
        d=google.com; s=arc-20160816;
        b=JQ9XL43448qBvv1QWClMQndE/s6i3NtG41yRqdc+zEvi5gFPy8PfKxSlAjcspUMsa9
         2rZEngHVzyWpWEGRHgTLe1VVHX6SemnRkhsYYa2SyVmFw6x8peZLqmtHVJdNuUgqwo+Y
         rqj/+2WS8dNi4nljCDWWAJ/FNjjK8WE8s/VTSOwXWtWBaXoK3kSsLUOBfddnFkVwSQFp
         Bun2LasJyj8+LNHAwharkF8zdojfN+j9+PIV9UVJm13W1bOhaHSBB1OjT64KBOAVf1wY
         pKQ41ch4/1oFL3hmHi+4MKOhBDI8EEFYv71FvjuopsSflD4keQNrT1WDmoWuRaA9e3ib
         xUrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gw3F6//qpgy8BIP5lrC0jqrOUsmk1iRbGI4X92QxuSU=;
        b=nl/KfNEj0yUs2R8Rm0VS7skxbBOZJ9aTHxVlbBr9DBIG03BY8LDxZjfrBZKPTPkDNm
         EMCzWerIP9WMuEA/5wTG2IMqZ13tGEPwAke9QBgsZlyqUS5wCKWyzZOfNl855YKuRmaI
         W3N6GeEX/7/UyBCakLgedYTxAhamV/9b2mcr77MU6vcJ1fPVsCAVny7/JyxpqCp/xelY
         trifW5BIXYA6zsZr3wR/I5ar68qbPSliQaCzf8FnyBZaj7I/e22FhBJ+W9CdNv3uKKrR
         PlyPaB0K0aO+3vW7z1P5nD7og6TR4FxfMRrAfjT6siYY8NgBQ9Qj555PLVz+vy7lmERX
         TMnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m5si80981950wri.250.2019.01.28.08.22.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 08:22:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id B1D5A68DCF; Mon, 28 Jan 2019 17:22:56 +0100 (CET)
Date: Mon, 28 Jan 2019 17:22:56 +0100
From: Christoph Hellwig <hch@lst.de>
To: Christian Zigotzky <chzigotzky@xenosoft.de>
Cc: Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org,
	Darren Stevens <darren@stevens-zone.net>,
	linux-kernel@vger.kernel.org, Julian Margetson <runaway@candw.ms>,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	Paul Mackerras <paulus@samba.org>, Olof Johansson <olof@lixom.net>,
	linuxppc-dev@lists.ozlabs.org
Subject: Re: use generic DMA mapping code in powerpc V4
Message-ID: <20190128162256.GA11737@lst.de>
References: <e11e61b1-6468-122e-fc2b-3b3f857186bb@xenosoft.de> <f39d4fc6-7e4e-9132-c03f-59f1b52260e0@xenosoft.de> <b9e5e081-a3cc-2625-4e08-2d55c2ba224b@xenosoft.de> <20190119130222.GA24346@lst.de> <20190119140452.GA25198@lst.de> <bfe4adcc-01c1-7b46-f40a-8e020ff77f58@xenosoft.de> <8434e281-eb85-51d9-106f-f4faa559e89c@xenosoft.de> <4d8d4854-dac9-a78e-77e5-0455e8ca56c4@xenosoft.de> <1dec2fbe-f654-dac7-392a-93a5d20e3602@xenosoft.de> <20190128070422.GA2772@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
In-Reply-To: <20190128070422.GA2772@lst.de>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190128162256.JqDmRWCjSie3gSUb4y5tr2unlc9_f-kuxNssCOy_VQw@z>

On Mon, Jan 28, 2019 at 08:04:22AM +0100, Christoph Hellwig wrote:
> On Sun, Jan 27, 2019 at 02:13:09PM +0100, Christian Zigotzky wrote:
> > Christoph,
> >
> > What shall I do next?
> 
> I'll need to figure out what went wrong with the new zone selection
> on powerpc and give you another branch to test.

Can you try the new powerpc-dma.6-debug.2 branch:

    git://git.infradead.org/users/hch/misc.git powerpc-dma.6-debug.2

Gitweb:

    http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/powerpc-dma.6-debug.2

