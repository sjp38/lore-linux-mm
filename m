Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE263C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:28:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83B56206BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 08:28:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83B56206BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 222698E0012; Tue, 12 Feb 2019 03:28:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D0A28E0007; Tue, 12 Feb 2019 03:28:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E7438E0012; Tue, 12 Feb 2019 03:28:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id D79128E0007
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 03:28:55 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id y8so1944401qto.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 00:28:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rPkw1S/ntnlQuSDvUUJ9fbVyHoIJ5wkiqOmR7my401c=;
        b=TJ7E6OTjv7YUeTc4XtlKCTp49Wg9Zobdgdotty6hXw95FOBtvcWoe56UejEIMi89cv
         v0XxBfPnFC5fUfbRjt/gw/gCE1y4gL1XA7Px2dMjdekybPX9LfL9IBoreeOa48xr8dPn
         1tjCvUwmCg5LfAapZRe4wAwn/yU7DqDR674qHmt+0YBInKYrQfW01cd6cn1ma7rVwX7d
         m5yr/dw7OWm9hX94xT90UhzYu0K0TWvbDpFnKvyKVu72k2o+erFlLQHktssQmBGXB22L
         MFv/oMTzDfvr3namYAa9kYuo9Ng1ggUBR2wA18GHeI12VyO52+kVz8cvcyJPzJpuYBMF
         s1aw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYJ9F8OFBuSfOOFnyUoE5ysw1KvM0ifoJpQMzGIBPthrwxpsiJ1
	oLZljHElE/BL+GeY4tc3bXuGMnk/2kdJsD+/lOkSXHd7Bs4u07nZ1S580ikSkdevI/7lduvwxLc
	zdNx/Puo1OKTurewiA0WZ/9OaBZOHL4toExJ0wbKvVj3+4qPe01TjO1EOM1ZjUkCKTA==
X-Received: by 2002:ae9:de44:: with SMTP id s65mr1773413qkf.55.1549960135595;
        Tue, 12 Feb 2019 00:28:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZrI84n8bTQ2XGpxeUN19dsLhoK1o1QAmshz8Dn+yqgHY0+PYD9KVKOIiK3jfE7GX2xikZX
X-Received: by 2002:ae9:de44:: with SMTP id s65mr1773393qkf.55.1549960134921;
        Tue, 12 Feb 2019 00:28:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549960134; cv=none;
        d=google.com; s=arc-20160816;
        b=O9OQKga8TVwEqY9DZ7kj85a3HHJtzbg8gdEg4uT/vwLJEgzz9FbPpebyQ/MA6238Bl
         rcgJBr6b6+SiZi2WFLYwOcrnrh1MnXBgh5oJhZzCODR+C0KWPmSzUsQA8QynvvhRFN89
         C/mihcQQjgdrxals3kU402FGgtBDrqtzHq2qBF7XbD+BrdV/xce1JJoWq6NeMfFhLd+Q
         +T7SD23w7XzTI334nqMEdgRkQART/33/A6H2djG1HcMqZE5LLkCb1C1JL1AVTfqVyzsV
         Wi/T50kBOWjFx36iH+GNLd1jB2UD8SPuxN09opDoPGhaThw9EVwNwEYgFyT+cRMDn+L5
         HonA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=rPkw1S/ntnlQuSDvUUJ9fbVyHoIJ5wkiqOmR7my401c=;
        b=xpre5gYg/pe78HJwxRmvCxp3uEU6g7t6UUXC8EgYhotnkP84WQ7Vxi/VdLy5SWUOtk
         JoU5y6QrTeC7cUEzrx9pUlZ6bDF9PWsZvo9y+Gpw0U+8BZAKXq0R0gxTxgA7QwkBvLqC
         IcDjZjaxpaJSdHsYXnJ42uAJ8ZMrDsbxxzyDv2D+BOF1dTkE0r08O55HbAhwitmtVTFt
         cwRWG8O+lbEi1DYE2T2npZa3oXGn+iZyKNlEd3L2nSyLYF3eN7YMolLJQh7mY9I66T07
         0WNfXUlR6S5fFTVqhGNgj3FoJ5IV8dpzgMMbYk6xAHPvj8eUOceOGmHSG4vLiPRDDD3y
         E8ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l7si2101682qkg.96.2019.02.12.00.28.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 00:28:54 -0800 (PST)
Received-SPF: pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brouer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=brouer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0B230C05001B;
	Tue, 12 Feb 2019 08:28:54 +0000 (UTC)
Received: from carbon (ovpn-200-42.brq.redhat.com [10.40.200.42])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8975A19C7B;
	Tue, 12 Feb 2019 08:28:47 +0000 (UTC)
Date: Tue, 12 Feb 2019 09:28:46 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, Toke =?UTF-8?B?SMO4aWxh?=
 =?UTF-8?B?bmQtSsO4cmdlbnNlbg==?= <toke@toke.dk>, Ilias Apalodimas
 <ilias.apalodimas@linaro.org>, willy@infradead.org, Saeed Mahameed
 <saeedm@mellanox.com>, mgorman@techsingularity.net, "David S. Miller"
 <davem@davemloft.net>, Tariq Toukan <tariqt@mellanox.com>,
 brouer@redhat.com
Subject: Re: [net-next PATCH 1/2] mm: add dma_addr_t to struct page
Message-ID: <20190212092846.109c9bdf@carbon>
In-Reply-To: <20190211121624.30c601d0fa4c0f972eeaf1c6@linux-foundation.org>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
	<154990120685.24530.15350136329514629029.stgit@firesoul>
	<20190211121624.30c601d0fa4c0f972eeaf1c6@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 12 Feb 2019 08:28:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 12:16:24 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 11 Feb 2019 17:06:46 +0100 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > The page_pool API is using page->private to store DMA addresses.
> > As pointed out by David Miller we can't use that on 32-bit architectures
> > with 64-bit DMA
> > 
> > This patch adds a new dma_addr_t struct to allow storing DMA addresses
> > 
> > ..
> >
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -95,6 +95,14 @@ struct page {
> >  			 */
> >  			unsigned long private;
> >  		};
> > +		struct {	/* page_pool used by netstack */
> > +			/**
> > +			 * @dma_addr: Page_pool need to store DMA-addr, and
> > +			 * cannot use @private, as DMA-mappings can be 64-bit
> > +			 * even on 32-bit Architectures.
> > +			 */  
> 
> This comment is a bit awkward.  The discussion about why it doesn't use
> ->private is uninteresting going forward and is more material for a  
> changelog.
> 
> How about
> 
> 			/**
> 			 * @dma_addr: page_pool requires a 64-bit value even on
> 			 * 32-bit architectures.
> 			 */

Much better, I'll use that!

> Otherwise,
> 
> Acked-by: Andrew Morton <akpm@linux-foundation.org>

Thanks!

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

