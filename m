Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1DC1C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 17:11:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4FD8208C3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 17:11:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="e6wUwdxW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4FD8208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27EA46B0005; Fri, 10 May 2019 13:11:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22F186B0007; Fri, 10 May 2019 13:11:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11E696B0008; Fri, 10 May 2019 13:11:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF09C6B0005
	for <linux-mm@kvack.org>; Fri, 10 May 2019 13:11:13 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id z12so4465699pgs.4
        for <linux-mm@kvack.org>; Fri, 10 May 2019 10:11:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=RN9MRAYL04J62QQlXQPaUff9V9wYHA8yoc3KdaVugcA=;
        b=jGJPI8d4Yte8IKfjjlLeUfXqZCodIMLcudRrqgWbNvbnpAWsuxcp9fPeWLWrlqBfgf
         ZnrsBBAldP/bZBVMeLZq97lRX+8CDow7WJCWQwDE1Jn+YrkcJ07aMUXPxV2eUetx36b6
         vkIIFNh/qzVzqGjt/2XraQ26oxaRB2oxNt/LtH6ca0jMXXVm2njS0Z4zbcySgb5CNK8h
         1UTLQq24pOJIgjl7kL9kI1kndh1uDF+AxYF2uZVY3JM9yHqP1KcRAGS9mRrGgEnLvuIP
         TK6Q4ePyqTq5owzTRcNZATeK5Ndl6An2ThRAcyIlnLySQTeE8AAEeIn1JsdHTNVlegA1
         rGZw==
X-Gm-Message-State: APjAAAWyQQ9Rpd/63wndq1tZs39AwYNYcy//71Z99Y3Vnx2YpYzxUY+u
	6H5a4Q19jcmR86ku5pJNqWP0b2t2cxNAzhn/1cNISfSH1kmcWF/80SazsbYDfF1zZzesdpp4cCp
	maCDA337hJHSevKpCCqb1tw2z7Mx1CdgCfji9jAkpDyK7bHggr/0ob0Dj8Tk1A4701g==
X-Received: by 2002:a65:5003:: with SMTP id f3mr14776774pgo.336.1557508273420;
        Fri, 10 May 2019 10:11:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyisa7F0YAh7DmQw6v7/YeHuOWSYG314FQfpBBOZAzu8ns/Bolx8Bdkcoz6EflTpxkgMnHh
X-Received: by 2002:a65:5003:: with SMTP id f3mr14776657pgo.336.1557508272450;
        Fri, 10 May 2019 10:11:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557508272; cv=none;
        d=google.com; s=arc-20160816;
        b=FSOAbla28SG3rgMVKeCasbLov0FdfKNPYg2FoQak9haXciXCWNQE9GCWvNf/IrMxlg
         Cb6St1G2grB1PatTNt7D7qnSoz1+u03KFOik9pHqCFisJliL+bH7hs9/HPrMJiaAKOzm
         FXHGHCVF3PLqTlv+H8nSo8PW35ovlo5zpl+bpisMyd748GFTekWar6oYDV4L0ITMQUVn
         dfjre3z89QTTaZTouUWMwv6KbTLovdkIM+Uwi1MPmZ/dU+cIiPn5jt1vxYwppbLGzqhv
         +KBblj9HeqdXAXZlpvi7RIiJDz/DZmlz3X9HwTzajggy18wTcV5MgiYEDiuZzqpaBVT3
         k0JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=RN9MRAYL04J62QQlXQPaUff9V9wYHA8yoc3KdaVugcA=;
        b=u2n9iuTm688pousXy76dwKl25zIg9NFQLn7SvPWFJmOrCMfXIdys9yCAqveukZnrwf
         EwMKvMN1USaCxWA2CGByAyD3uuow/tXGQN9nkU5MhIBYUQJeD5y5xA5vFfjIDPrr3qvZ
         ErFLoCso9wAbBtXRJKajhOajYdLpViiQFlhMSVdZrgPA+dkkS8IFtEVy6dwSxNqqrOFd
         lCU5jE33rLFPTcgSIh4qSL/+aiyJ3HGjcbNIRs+HqM9t+M3jefmP/H9d1Ulf1ciMxbVx
         C5zjIAHBdVzzZSug4TAra4DoHiz5es7+k6GP9AiGgvY512I4Dw+J2J/fORcabd+/XOJ3
         +z1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e6wUwdxW;
       spf=pass (google.com: best guess record for domain of batv+4a48006d3eb72708861b+5738+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+4a48006d3eb72708861b+5738+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z11si7770752pgv.333.2019.05.10.10.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 10:11:12 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+4a48006d3eb72708861b+5738+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=e6wUwdxW;
       spf=pass (google.com: best guess record for domain of batv+4a48006d3eb72708861b+5738+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+4a48006d3eb72708861b+5738+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RN9MRAYL04J62QQlXQPaUff9V9wYHA8yoc3KdaVugcA=; b=e6wUwdxWd9wR3TUAIHqoYksa8
	w5RgqCu64V287AQTt+74ZJrMoOl3W7+WQSRzar+7PaFRuOH3yfmUwy9ctvV5PgoHi6ZKikdg5+teE
	XQ+UIA77q14N2k0AT5C1MufgBRXlFOnKGROzxrDHQAeAThM/uYPGO6Fs8EoVwnuXMNgBYBeDic3kN
	zHhEIa3n7nVSnFcGy8OMJNQySOMVMV215h4+BsbhTWUYIN91De7jQOGmeAMjz+ZrLAHzuGv2eJ0k6
	P+UYM+mHVELGhVyfx9eTi7a/AgKhkJQ07/2bOMQx9B7soP8XUY4VQnzoEijWaFnO13E0+uASEW5wt
	XtvkFZUuw==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP939-0001ng-08; Fri, 10 May 2019 17:11:11 +0000
Date: Fri, 10 May 2019 10:11:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: Bulk kmalloc
Message-ID: <20190510171110.GA3449@infradead.org>
References: <20190510135031.1e8908fd@carbon>
 <14647.1557415738@warthog.procyon.org.uk>
 <3261.1557505403@warthog.procyon.org.uk>
 <20190510165001.GA3162@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510165001.GA3162@bombadil.infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 09:50:01AM -0700, Matthew Wilcox wrote:
> kvmalloc() is the normal solution here.  Usual reasons for not being
> able to do that would be that you do DMA to the memory or that you need
> to be able to free each of these objects individually.

Note that you absolutely can do DMA to vmalloced buffers.  It just is
very painful due to the manual coherency management..

