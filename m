Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E59FC07542
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 16:55:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF45920879
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 16:55:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF45920879
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 248236B0003; Sat, 25 May 2019 12:55:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D2046B0005; Sat, 25 May 2019 12:55:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09AB46B0007; Sat, 25 May 2019 12:55:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BF7306B0003
	for <linux-mm@kvack.org>; Sat, 25 May 2019 12:55:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id h2so19723424edi.13
        for <linux-mm@kvack.org>; Sat, 25 May 2019 09:55:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GJj3hIfAn3cU2ex93hcX7WwAvCxSQYkAxDku8awVVuc=;
        b=glmuFTHDF5B6zmaHuOr0Yyq924PqzgW/asedx3dxTMGvEn1sFXN/WRUGq25wVuhoTm
         jV6ZrAQsuD2CKaq4R1FuLxhqfZSlDunI4uW7feHEkTHyaWVKunn6aOW3NUrN/slFgugr
         BNWk0ZNMjlvy0BW4Yeq8NhiTlifYQzdgIykM563r7TyqyHUTT+fQ09Lc7OOXc49/Gn8I
         ptOajl1fchI1shte3HSk7vXuwXBwm9HEGiAtcKKFUtuuCSiaCUWreiMoZr49KLvr8iA7
         ARcGpW1l9pzHlsMkpG1sxPOXEdfED+09GpOcBya/SCo+5fpqqHPr2KJ3YIRYbTPFn3f3
         Opxg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVhUBhwXIq8vBpMnil2HqxQWfnFTMx/TiuA/pG3fuCHW0C/xvia
	79jPIt8ImzV3ryGJibCKh6QRh5Z1SDngGgbs3uefWqNAtKJrAzYWhAT7n5OFoqgXGZP/pL+8ntW
	F033um923ZfPTYl5ZCk1E2ZIyEgKAp8ycGD82nxgZmJ+CAQ5ZfE7lIuufHGqaagE=
X-Received: by 2002:aa7:d0c2:: with SMTP id u2mr7625211edo.303.1558803306250;
        Sat, 25 May 2019 09:55:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9v0+VOjYBbnqsdCxdDMuplbGbnm1DwOH+IX/3oMbC7gLyIU5SVuE4gvg9x556Y5aTMh5T
X-Received: by 2002:aa7:d0c2:: with SMTP id u2mr7625167edo.303.1558803305452;
        Sat, 25 May 2019 09:55:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558803305; cv=none;
        d=google.com; s=arc-20160816;
        b=cobuj4VrcfW0deiwW170EwR1J4jS0P3LFaxjp+8W9b3D+dilSDGH4J3EdNCHaT755L
         N4+vvvL8TldfFYnPoa9OPQny572ZrRzwGXqfDkNUueuQvfWxSD/s0neJ5hRuCBcX7K9A
         tzpnOKmyJCPPhPN3/6RKtiIxdK/caIr3wYTMCaiRhznOWyB88oIwaI6oeLznNJ+rwhFe
         y/opyhGJecvhxagNkUOzjjauZYVD1h4DNLxDS9law+c/4SwpxWOX8kKZ9T3Bk5MkNNEb
         dOCYD0aNolyFBx88QWm46wsz+rYrCClrQ1URfd0a7M0SqUD1SqHW5z28GYANQbg1SKqK
         oUjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=GJj3hIfAn3cU2ex93hcX7WwAvCxSQYkAxDku8awVVuc=;
        b=njnCDHmrBU6ioPPdUaTa/cqmNn7Zw0N0KyCLo0/EsKOoEOfKMQu0jt7yFanlZwt+q9
         18LdSk99QU16cYBBU2UsZj0bXYYfQFJRYp6R3Tv/y8PHF7/NzAZtU484pJdxL79vmRUn
         1ifM1LjCNnsMN2RyIcyIPMTAfMGTHefgrNePVP8JBNxBI2cYtWJiF9NXWQ7Bq7BQHXN3
         ZQwxSAONWsOe8kM7QHcWq5n7MkzhzXoVOy2wv2+lN/NOnvmzHDRUZTSlgt2fLb9tSscA
         AiPolWI+ITrA+1y8Vom/BsuofGDqHCC5sK3EBGqpeI1rrtgE/JWcnxcICmzuUkdK/2ta
         f1Ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id w51si2797241edc.15.2019.05.25.09.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 25 May 2019 09:55:04 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d8])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B527D14FA25C4;
	Sat, 25 May 2019 09:55:02 -0700 (PDT)
Date: Sat, 25 May 2019 09:55:00 -0700 (PDT)
Message-Id: <20190525.095500.1447810293414838145.davem@davemloft.net>
To: hch@lst.de
Cc: torvalds@linux-foundation.org, paul.burton@mips.com, jhogan@kernel.org,
 ysato@users.sourceforge.jp, dalias@libc.org, npiggin@gmail.com,
 linux-mips@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 5/6] sparc64: use the generic get_user_pages_fast code
From: David Miller <davem@davemloft.net>
In-Reply-To: <20190525133203.25853-6-hch@lst.de>
References: <20190525133203.25853-1-hch@lst.de>
	<20190525133203.25853-6-hch@lst.de>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Sat, 25 May 2019 09:55:03 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>
Date: Sat, 25 May 2019 15:32:02 +0200

> The sparc64 code is mostly equivalent to the generic one, minus various
> bugfixes and two arch overrides that this patch adds to pgtable.h.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: David S. Miller <davem@davemloft.net>

