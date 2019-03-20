Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46939C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:04:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0795521841
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 20:04:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="HPpQBz/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0795521841
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D2F96B000A; Wed, 20 Mar 2019 16:04:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 782186B000C; Wed, 20 Mar 2019 16:04:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64A4B6B000D; Wed, 20 Mar 2019 16:04:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 43EE36B000A
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 16:04:35 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x12so3722294qtk.2
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 13:04:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=Vo6r5RiuoHQQbBcC9iguZtdqZ6ajLyJa96gCdeOiWbE=;
        b=mEKsWwP/kPKAeENRh8cPcz4fpAVW2AP9tdE/iuRJvKpn6SwJrCZ948HPL6aZ1a+qBu
         X67KqDnEaSmOCTBTIOUOsAvR50valxIAikxAiqAg3vJGNnEthnx9igRkxtLkyTISHxwt
         QwRDZgvMj3uGMsMUShWmgzYnGkYU9AlQjfo0sSwO4ouqwd4i7xOjnyorvYiQ0t+680aq
         Pg/CUX+Q/Aw7BC2W46ioI4WoDHdMF644yRpfUB9mX8tAqywEuybZh5O8rYyPZeJWgSxb
         kW4ZEdvIB9u5IiaCnCzmKwV3V/r13wpE44wgAgMDbW/KEa8xUo2UegyduNdHqKOAv6jt
         duvA==
X-Gm-Message-State: APjAAAXv59eZpj4gA+CbQM/rAdaF+sHl/mlHsuwYkYqPo9iRB8M2fkzr
	FgPCAolpph8a/dUUbnC42MHfqTWvHA3eBzVbPzzKKy1Hb0JziIJg5xBCoj+GrGE8jr2L0cB2JPW
	yMWmoUQz4oBXOhuABgkKsX248fE3YWvcw0HjP/2fZQu0tu2FclD4j1BiDBw0+fYvjsQ==
X-Received: by 2002:ac8:54c:: with SMTP id c12mr8486454qth.327.1553112275046;
        Wed, 20 Mar 2019 13:04:35 -0700 (PDT)
X-Received: by 2002:ac8:54c:: with SMTP id c12mr8486409qth.327.1553112274405;
        Wed, 20 Mar 2019 13:04:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553112274; cv=none;
        d=google.com; s=arc-20160816;
        b=HpdxSbikVsCi4KWQvVikdKBa2NkSmF7RMLUO0AIg66LeGYP+QRe0iP8h0tlIzIlQF8
         q2g8x2QLdBTKIdseHUoH007zDgk5cYQlvxZUPR84eTiuSfKPTxXIV4JAGiusUUEAoaSB
         THvsI3yUJVjRlPdf9oWcqu0hv58WYOhf6bLdSoFYMdSLtfUKUi+TY7OPDvr1WcOsC1b0
         8ZUfVuBHdlckTAqa0iVR+Dy5BP+jrrTOlaYFgeuYPyKz+AuKvmH5vvKBe6YQXUASN67E
         8Pp8im1qTwDsEZDdy0O1JE4fsywy67XNmEj9Ld2xJAvPxt/ahzbsCQpAqhpqDCjdO/Yr
         HVmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=Vo6r5RiuoHQQbBcC9iguZtdqZ6ajLyJa96gCdeOiWbE=;
        b=A+YEK+nIExZYU5z6nwhOYBZas60r6uum7nidJfUeNa3yJzaIxqwehBEtCpcVYnp34q
         hEO/X4i1QlFaP3mr0YV8qgL4Vvqc6znpwb46TJPl6KVpbJ9mXA7MQopwNTXUEHiyOL2a
         170TBWtxx1PfKlUpojTFSLoJUV+N1nxCINwxqIeHSXJQrmXIDtbrvmzilhhPLiWNIMgX
         lAjLxFPZs2WtLy+DvvER8MXsoU0dnPz89FEW8TFgQqfGKvBZYA9kRXiULhQgJ36eaA3F
         SuYE7Fap9M1X1PVU9fTf7f85n1pomO4xWEYZ9oLqAaxUyHzWtTEEQdam5Mg1LgMST0eX
         brtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="HPpQBz/C";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w138sor2235485qka.131.2019.03.20.13.04.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 13:04:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b="HPpQBz/C";
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Vo6r5RiuoHQQbBcC9iguZtdqZ6ajLyJa96gCdeOiWbE=;
        b=HPpQBz/CvqsFaa0YHkIdIWC9iwfw02s4wfgNx/cLGOHj1a5FGWAnDDpEotjpjx0NSL
         F0gyFf/ieAD253cjGeiAI+MkOvyvKxGe61VtSSWQyyRJBaP7ihSFnE/JoVW2e+vyFmJ/
         oOS7inR6aNpv0mA8RAyeReJDsdd38nUMURgiM9zWeRT4BPqOg5Djdld7zvw2Y8Eov+n7
         /YZmRaOdN3FdNQJFu/QU8RFIhdswP6VC6E+Es8DpHWFEFDgpkO5rN/P+p1FBRmPnU30m
         WYfL0DDwwyVAavff0M6gTimy98fqUaF3Rinq/8q+m+aNdLDaewlmpV8kawsjV23Vwx7s
         G2Fg==
X-Google-Smtp-Source: APXvYqyNcoCpTrG/QlxBIiS3xOXvYOWD0i6x08P3+8eR8pgFrkDCEqYQr79GX02pD2JjjO+rwwfWzA==
X-Received: by 2002:a37:4d52:: with SMTP id a79mr8186639qkb.75.1553112274192;
        Wed, 20 Mar 2019 13:04:34 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id h24sm2225964qte.50.2019.03.20.13.04.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 13:04:33 -0700 (PDT)
Message-ID: <1553112272.26196.9.camel@lca.pw>
Subject: Re: [PATCH v2] kmemleak: skip scanning holes in the .bss section
From: Qian Cai <cai@lca.pw>
To: Catalin Marinas <catalin.marinas@arm.com>, Michael Ellerman
	 <mpe@ellerman.id.au>
Cc: akpm@linux-foundation.org, paulus@ozlabs.org, benh@kernel.crashing.org, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm-ppc@vger.kernel.org, 
	linuxppc-dev@lists.ozlabs.org
Date: Wed, 20 Mar 2019 16:04:32 -0400
In-Reply-To: <20190320181656.GB38229@arrakis.emea.arm.com>
References: <20190313145717.46369-1-cai@lca.pw>
	 <20190319115747.GB59586@arrakis.emea.arm.com>
	 <87lg19y9dp.fsf@concordia.ellerman.id.au>
	 <20190320181656.GB38229@arrakis.emea.arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-03-20 at 18:16 +0000, Catalin Marinas wrote:
> I think I have a simpler idea. Kmemleak allows punching holes in
> allocated objects, so just turn the data/bss sections into dedicated
> kmemleak objects. This happens when kmemleak is initialised, before the
> initcalls are invoked. The kvm_free_tmp() would just free the
> corresponding part of the bss.
> 
> Patch below, only tested briefly on arm64. Qian, could you give it a try
> on powerpc? Thanks.

It works great so far!

