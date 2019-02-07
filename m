Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 195A8C282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:42:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C69662175B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 21:42:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="Tq8oB44z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C69662175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5A1288E006B; Thu,  7 Feb 2019 16:42:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 550238E0002; Thu,  7 Feb 2019 16:42:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 440138E006B; Thu,  7 Feb 2019 16:42:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id E12CE8E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 16:42:42 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id l18so303291wmh.4
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 13:42:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Qx+TUyFynWwI5KhCI9PcXSu3iAJe4wwFjtiyfwFfwT4=;
        b=R53uO7akZp4NZGlBxFBLmrfkQFd2uE5eYbvhTCI7OA1uAqPabsg0GCwaPimRlo9ceU
         Eal8y5CWBoxLxtbR9PDvFxoFvzHBrVp0ovSwAcC/phgjv8s4kO5GqpzPzhBgU/zLxGOq
         ewSpXKN1izHygcgghpDIdv4dksZ9sHs/0UNcZ+Nig0dcDN3IWfDrVkEaVHBoFE277/MW
         53ea36relgNtq6qa9N1vZzrIhPhn6XX0GOkz+G2zd4KpM47N0LkCAC4CdvVvj3/Qrd7E
         MRXdNHqOBE0V1fbP/0NstfJp7HVZDw8BG0ZKhAnVTp6sCltp9thzoy451jRMg0NnbxIM
         MN2w==
X-Gm-Message-State: AHQUAuaqL2SUGa3HytkkzjLDfCus42s1xrbgrRKHduVc2lm7Kv4TLWo7
	AEPRIVCSqvRvsA7/ppZl8FLRkqFzrFwOIsWqg3nl4yRwps+v4wi5v1I8SqK+7IIxdnz0ItdtgTi
	rQTcb4wHT+wM1izoTWiCxPLj3COPyEfktd8uickAxTtFvLni4Db2agf6KWkhjkvpakiUmoPNWY8
	NH3fHr8514Vw/pIt6uVnnhgzJMP/9kX61zl2/Pzk6KZk17pxENGWmfgudgoSHuX3E14GH4ia+fG
	HKlb8H3DXDpq2PMcB/2U2c+JzoYQtj8kuxWjQz0hCqLuNKaQCd/3lS5dHbT52PzAxPZBQ4IiZ0x
	Xd2T37muFfyG8uApjf+OkSx55BCfcW7kVg9pv0+kXAkaUnPWbLwEdBBmYTyzaw7+hAKUNul9JYu
	t
X-Received: by 2002:a7b:cc03:: with SMTP id f3mr8372161wmh.95.1549575762359;
        Thu, 07 Feb 2019 13:42:42 -0800 (PST)
X-Received: by 2002:a7b:cc03:: with SMTP id f3mr8372135wmh.95.1549575761547;
        Thu, 07 Feb 2019 13:42:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549575761; cv=none;
        d=google.com; s=arc-20160816;
        b=btwI3rJJRxtdF4IbEedGRZRUQcE9rBSjRz3rt23Ahg8h3/Y3N1KSxqKe4I1PEEH2Xt
         V8Zyxb0tFJgznqLbsLxK5HmyN+M4OO0hLWmtTyESUcxCOAQ4jZyqFy8Fs1lqtCSKjciJ
         ef1Z//XaLsDGT5Sz7n+ZLH+I3RNiFv/RU/8JumRfeaihyahAWTOsXaH50zPPlr9Nxz3i
         xL4y9SE7NtO4StSg1WD7R5GCbepOsWUE5d4XG7If6jDw02II2I1UzKMEGm5Q0CqumiY5
         RKSzZY+47rz24D+Da2RGUp0b9Srdy03rsqBu5RT2jQOYtzkcoFYi5I3yZKeV+Fll/Jwr
         MpZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Qx+TUyFynWwI5KhCI9PcXSu3iAJe4wwFjtiyfwFfwT4=;
        b=XNhlKxTqhQmQ2rQu9rz0lKv0YLbsoeJRLXedQrkkvK86bJzqX2g9E5tZZU1caTogDL
         ZEs7srdyhslMEqZJNEZT5JFj5/BW6aZUNhyQT7DD8JCd5V5Yw72ykn7PE+T20Dh67qnG
         niAfcPNBdTiFcsMsk3Ph4A0GyDCUg+Bzxo9I7crFfjp8U473djQ0fTNx+kcthDG3MV8r
         9LMKqPodxbcH3oj9w+1h4a1kD+Zy0Bf+Crlz4jt20i+3CFHpt+LFZSly101Jm9DjontE
         cDpcuLT9wkX58vguWYO1xdmqZGfD8ASi0LlrSvUeA+6VSP0LuadfDt8qYVEqjFbgJkxa
         H3mw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=Tq8oB44z;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l1sor84000wrx.26.2019.02.07.13.42.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 13:42:41 -0800 (PST)
Received-SPF: pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b=Tq8oB44z;
       spf=pass (google.com: domain of ilias.apalodimas@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=ilias.apalodimas@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Qx+TUyFynWwI5KhCI9PcXSu3iAJe4wwFjtiyfwFfwT4=;
        b=Tq8oB44z+mcyoIvV/vzLjRbfSxMWsokLRaWhIDe3CysWa4gG02k90luF5eHMa5ReB7
         M8HYiEKRTt8OLJ353ZFTZw7TMTL6kTwa4aMJr9LvhZBG5tvh/eIgYWPdU3Xx/roPHxGZ
         AMLRlOxG12GCedyD5l36EbMs2XhEnXFLTioUZE1wHZsiMfWBHN8uOv9KKDD5xESJFgY3
         Kkk0/QBj0JEYbmdsTNwxiYz07T/voemOQGlRnCoC91rlllYwWxojD+oapJ6PRpgHZenV
         MWtHKjlmHfQfb0hTxjQOdt1YiIJq1p80VOe7nYHkFQxQhz+6njbrrvQrDzKy8l7il5+b
         he+Q==
X-Google-Smtp-Source: AHgI3Ia4FJgVQ19IPgjc0GgQ156H2vm0SwFc9gOm/r8e+JrKyKQMu7W2+wrRk9kQHELcBaYYXDuQfA==
X-Received: by 2002:adf:f390:: with SMTP id m16mr13382272wro.71.1549575761046;
        Thu, 07 Feb 2019 13:42:41 -0800 (PST)
Received: from Iliass-MBP.lan (ppp-94-65-225-153.home.otenet.gr. [94.65.225.153])
        by smtp.gmail.com with ESMTPSA id y8sm700573wmg.13.2019.02.07.13.42.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Feb 2019 13:42:40 -0800 (PST)
Date: Thu, 7 Feb 2019 23:42:37 +0200
From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: David Miller <davem@davemloft.net>, brouer@redhat.com,
	tariqt@mellanox.com, toke@redhat.com, netdev@vger.kernel.org,
	mgorman@techsingularity.net, linux-mm@kvack.org
Subject: Re: [RFC, PATCH] net: page_pool: Don't use page->private to store
 dma_addr_t
Message-ID: <20190207214237.GA10676@Iliass-MBP.lan>
References: <1549550196-25581-1-git-send-email-ilias.apalodimas@linaro.org>
 <20190207150745.GW21860@bombadil.infradead.org>
 <20190207152034.GA3295@apalos>
 <20190207.132519.1698007650891404763.davem@davemloft.net>
 <20190207213400.GA21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190207213400.GA21860@bombadil.infradead.org>
User-Agent: Mutt/1.9.5 (2018-04-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On Thu, Feb 07, 2019 at 01:34:00PM -0800, Matthew Wilcox wrote:
> On Thu, Feb 07, 2019 at 01:25:19PM -0800, David Miller wrote:
> > From: Ilias Apalodimas <ilias.apalodimas@linaro.org>
> > Date: Thu, 7 Feb 2019 17:20:34 +0200
> > 
> > > Well updating struct page is the final goal, hence the comment. I am mostly
> > > looking for opinions here since we are trying to store dma addresses which are
> > > irrelevant to pages. Having dma_addr_t definitions in mm-related headers is a
> > > bit controversial isn't it ? If we can add that, then yes the code would look
> > > better
> > 
> > I fundamentally disagree.
> > 
> > One of the core operations performed on a page is mapping it so that a device
> > and use it.
> > 
> > Why have ancillary data structure support for this all over the place, rather
> > than in the common spot which is the page.
> > 
> > A page really is not just a 'mm' structure, it is a system structure.
> 
> +1
> 
> The fundamental point of computing is to do I/O.
Ok, great that should sort it out then.
I'll use your proposal and base the patch on that. 

Thanks for taking the time with this

/Ilias

