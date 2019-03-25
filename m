Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ECC2C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:08:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED6B620657
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:08:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=digitalocean.com header.i=@digitalocean.com header.b="iEwEkuLr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED6B620657
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=digitalocean.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E1066B0003; Mon, 25 Mar 2019 18:08:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 790826B0006; Mon, 25 Mar 2019 18:08:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67E2D6B0007; Mon, 25 Mar 2019 18:08:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id 46B086B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:08:50 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id t66so4476117oie.3
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:08:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ceng7MEn+EPPEjmmMzg+oLfKm5kRneybZRwoX4/Yhhk=;
        b=nA0AslMJYu7gSEdx7/mcYFiGGacs7kDH5zGxElR0kB/UuhhNzgzQPXCrDgvGWk7dtW
         ITpIukYZI9tCTcr9mr+sY7qN1iLVPtaUX/z68JEqEXzfFwlailh2FkvktGEwOj2GWWos
         mUCSBMmClIq8kvb3FCk4iQCBUDiZJjqif3cUeJZl1J5ir9w5S9itd3HTVDWW+PKyISI9
         XV4YDyBQnePvG1B+3pv5rC/9sYOgyUougSEvH8gIbcTAhyfhNU8ICOOzKjnFOQunovcZ
         GAZXk+23NI2RkrpX7Jix0fRkbfCkeDmxJPjFlK8q9t88MJZWo+2qyP0ZhCplobku2MlQ
         mMyQ==
X-Gm-Message-State: APjAAAVCrFO8J2/q9mz9qbuJBAt4CBj3vWIcD93SQE0KqwctzX1TM8hw
	QLm+8i84sHteL57Glfkc4A77K1ZO7SMyWGmBgBbu3MJFvS+yqSrEN9YgfOJv5PwI989LASw164u
	MeL020IV1foK/mJ243lrY8c4Z1IGQKhsXfOH906m4mMGZ3yX7nokhASzozNhL0tHVVg==
X-Received: by 2002:a05:6830:10d7:: with SMTP id z23mr20290595oto.265.1553551729761;
        Mon, 25 Mar 2019 15:08:49 -0700 (PDT)
X-Received: by 2002:a05:6830:10d7:: with SMTP id z23mr20290549oto.265.1553551729124;
        Mon, 25 Mar 2019 15:08:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553551729; cv=none;
        d=google.com; s=arc-20160816;
        b=YHA1CU22w9lCvT7n8TMp13FYhA5wFXMUgK82IopKZYOzCirHdA4ht8aeMNAkosamMr
         Euzk3J7k0qr1vAiUc4DMKD58uDS/9Ds82JmME/6paYGL/6JdrmVLjK1pRjPT/NSIdoOT
         M9DLAihupfvuLezxwy9mNTZA30uswGeg2l1hi0ZNrCLy3cbIITP9GOpoCdLrMYNy2of5
         t0KR2z38hNyfP5zTJBiWHoLGdtSUJ5XDzxGHBNSt9ARQM4+7rOXC25HAmixABPFlduDw
         rK3ytDCPjhN2SVHHuSuj3nDgxPn+LHtdp4jdiXX+ADnJhUp0Ly7YSGFSjTO5bbvN3gDF
         03Qw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ceng7MEn+EPPEjmmMzg+oLfKm5kRneybZRwoX4/Yhhk=;
        b=tQliB0yBKSVYmRxv26+KQSwxh3o/LWTLbARYlTLn3MItO0akzbPzJ/wDr7uDYg7pSn
         YImJejiKN0XX/2oeEIrr3wJwDPlCRAIjkFO84ZKv4JgSd0S9b5hayy1wOD1Bc0W5Gky3
         qNNZDdZqj6odWskSL63TzEHZEQ+/f13vjrMakF9W3U+FJvTmMcr4LBt/cyhU6FcO2j/A
         mbVUjcLqcRXjAqTR9PHA7yj6QRUIeOO3WvHN049h8sNTCHg3EGtYEMpg1JWvWmqJDipu
         0VtQSFnvj0fmaOYL7EDpzVCe3CWfctguvp7LQ02CXIsZptN1lZr9CtQvNgrWO7YwLqWy
         wc8A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=iEwEkuLr;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k143sor6160345oih.149.2019.03.25.15.08.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Mar 2019 15:08:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@digitalocean.com header.s=google header.b=iEwEkuLr;
       spf=pass (google.com: domain of vpillai@digitalocean.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vpillai@digitalocean.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=digitalocean.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=digitalocean.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ceng7MEn+EPPEjmmMzg+oLfKm5kRneybZRwoX4/Yhhk=;
        b=iEwEkuLrMBSz5v9/dHyEPZUwbFpSwKLinA3PRBmhlN9fNjsJAP3GPceGjEPaQG99JP
         puIvSTbQaCQC36yfuDzkoDCXZkGKSh61rY97FinplPDryDWu/RRwlTTVMbw4j82LdK8x
         YoUDk9zxxPEMhfaxtyJJJZjh4r6j8zgKCcLVU=
X-Google-Smtp-Source: APXvYqzHOM83GRXD+UWdzuZaPmOZegv+xlU7Y/Er/asaSHzFxxZJnImRKhQcd9Tr3C3Xeuxkxjky67bANqPfxH6Zy7U=
X-Received: by 2002:aca:f511:: with SMTP id t17mr12775417oih.115.1553551728518;
 Mon, 25 Mar 2019 15:08:48 -0700 (PDT)
MIME-Version: 1.0
References: <1553440122.7s759munpm.astroid@alex-desktop.none>
In-Reply-To: <1553440122.7s759munpm.astroid@alex-desktop.none>
From: Vineeth Pillai <vpillai@digitalocean.com>
Date: Mon, 25 Mar 2019 18:08:37 -0400
Message-ID: <CANaguZB8szw13MkaiT9kcN8Fux6hYZnuD-p6_OPve6n2fOTuoQ@mail.gmail.com>
Subject: Re: shmem_recalc_inode: unable to handle kernel NULL pointer dereference
To: "Alex Xu (Hello71)" <alex_y_xu@yahoo.ca>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Kelley Nielsen <kelleynnn@gmail.com>, Huang Ying <ying.huang@intel.com>, 
	Hugh Dickins <hughd@google.com>, Rik van Riel <riel@surriel.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 24, 2019 at 11:30 AM Alex Xu (Hello71) <alex_y_xu@yahoo.ca> wrote:
>
> I get this BUG in 5.1-rc1 sometimes when powering off the machine. I
> suspect my setup erroneously executes two swapoff+cryptsetup close
> operations simultaneously, so a race condition is triggered.
>
> I am using a single swap on a plain dm-crypt device on a MBR partition
> on a SATA drive.
>
> I think the problem is probably related to
> b56a2d8af9147a4efe4011b60d93779c0461ca97, so CCing the related people.
>
Could you please provide more information on this - stack trace, dmesg etc?
Is it easily reproducible? If yes, please detail the steps so that I
can try it inhouse.

Thanks,
Vineeth

