Return-Path: <SRS0=IQlH=SO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9FEEC10F14
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:37:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C647218C3
	for <linux-mm@archiver.kernel.org>; Fri, 12 Apr 2019 19:37:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="jwIaWv78"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C647218C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 154E86B000C; Fri, 12 Apr 2019 15:37:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1051B6B000D; Fri, 12 Apr 2019 15:37:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F35556B0010; Fri, 12 Apr 2019 15:37:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id C87336B000C
	for <linux-mm@kvack.org>; Fri, 12 Apr 2019 15:37:29 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id t66so5104674oie.3
        for <linux-mm@kvack.org>; Fri, 12 Apr 2019 12:37:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=tZfBY8D1WgXooJQRUiHKhSamR6kz9YpYQFKQ9Eq/1hU=;
        b=oUsLV+ksBi5ZUGXHMdRz5lXwMMRuhH/2ESDuAjt/TTfdNPJq+StXQXpd8iU5OjB/rH
         weN0Zh6WT8dDbeEJaWrI/glRq47rG4FJUnG7OhKw6XNDoda4zW0XIzDGUeOCGrCYOtcS
         jUAU2v5LfXgOAbQ+kgrHYEJPKVbLYDHJQ1mLh7noVk0lR+N5ajDzBea8r0HxlOBQLfBy
         FkjC6pbfleuB7h31QEhcUnuYrAKFxe3IMCJPOhmkloYTv89XqwGcIwd64ttz23pczqe0
         AB+CFM+WYgyieHRHc8akmSbOo/b8ZWOEn20rZxv7v20ekoDDumdAh33eJg0XQqEx1Ke/
         cacw==
X-Gm-Message-State: APjAAAW56EMu1gVCo54/E71LV+f/UyyTOk/8k0xYGHarnEnowMeEkh2f
	8dm2PiYwxgUIoJx91vqaQ5zO2MwqHTyWxJFwGfZB7zuMnhZNMPV0QWB6jQVGLkZ7Rq/Fk3tf8cO
	EY+E1LujaJoYIP18ewI5iYBCkJoc0lK5hPytMwb/nPlk0AmB3b5ZtoldKYY7Ba6pRnw==
X-Received: by 2002:aca:b607:: with SMTP id g7mr11199865oif.6.1555097849288;
        Fri, 12 Apr 2019 12:37:29 -0700 (PDT)
X-Received: by 2002:aca:b607:: with SMTP id g7mr11199827oif.6.1555097848613;
        Fri, 12 Apr 2019 12:37:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555097848; cv=none;
        d=google.com; s=arc-20160816;
        b=UrhNpm1exJzR/nFD8Xxav2og0p0u2mPpoQwcVxuxtIL8TfnnQrMT6TABQwTSGwyTmv
         ScIXb9sOsUJ6R90669lgGn1aObT/bY3d2bzvJXdJHaD+gnOeU65Y3fj+zY+p/uDGdzBi
         xV/cqd+w+2RlgpVw7VEDg2cEJdQyPt9wqjEwzIcB9miYQBilBujsFfDXysI4bfYzNArD
         nPCuAvUq24tDUBCz22K4GLKr90nKg2I4f1GHLgTTogPcuvT3uB+j0zMkMII45V0H2MNx
         8JwRtmOYgPW3rUdSaFOhOv1tj5VTXOfwY+qD1tMIxY/QcY3sBwC8xHEMb1GnLR8cjEb2
         7RpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=tZfBY8D1WgXooJQRUiHKhSamR6kz9YpYQFKQ9Eq/1hU=;
        b=sPu7gHRZS97717LJm3J8Wr1GOaW//4zdT3g5RubchK2oxe+xJRDNynkJi0vsSQK4kc
         51Rsf9EY3QY/IfnN8o46ZytVsYF7tBVjZI072n5d6UbR2m4gC/9QfsJ3AxXXRrlpM9jv
         qL7+/TncBk25q2Y4B4wPWVLU2b+zx81e7DtmY8ilPptJcU/82/6ATJlzBmqAVIA3H9zy
         f28n2ZbWXJBn1YwfQfuDqxF2UdWf9l6+GxXfQyuLH8ZdEc1rxm9qjhbo5b58ARlXy8Td
         v/F4Z9EQH4LKgdZYucPP5oQSBWpHNk/+kBzGN1RfsnHmPHzF1yL8AVOwT/nsIicWORNT
         GY/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=jwIaWv78;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f32sor23874266otb.171.2019.04.12.12.37.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Apr 2019 12:37:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=jwIaWv78;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=tZfBY8D1WgXooJQRUiHKhSamR6kz9YpYQFKQ9Eq/1hU=;
        b=jwIaWv78fvkEa5rZbx+eP0fzYbqceSlvTJoR1XduCWAb2gsh8C3klYYgy/UEWlbg3W
         e1k5DE58xsWFRpnox+gDv2pxsyPeGd1VliXQdTqN/wjEe39t7A1LfOBY1Xw2oNp4IQFa
         izdMri970aizgvHVP7AGfoEDXy7apK6am+qaX0cHHnfXzrXeGMBd7PM/5URUlSE3Tjvv
         MU4YS4qovjxjhFGDBxrgmeU0ePJ2LKUa0pGMb+O0e+GfIn77BxF9oo+BRyxvHhW9LjqB
         xR/YJIrdWsl3PIAR/xzmCiHnNkkJXfmydSV2tKK7P3Oie3UkqJ0LeJfKW/5ZfXPUrnvS
         /+8A==
X-Google-Smtp-Source: APXvYqzhThKbq5GHetTkjSO5HdGMCT2FjO95YYhE57pp/4fhw00RFxMp33Lhq/TjtVDDMqbk9Vdgq3NV9eBZbTTkHEY=
X-Received: by 2002:a9d:3f4b:: with SMTP id m69mr37976108otc.246.1555097847859;
 Fri, 12 Apr 2019 12:37:27 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1555093412.git.robin.murphy@arm.com> <25525e4dab6ebc49e233f21f7c29821223431647.1555093412.git.robin.murphy@arm.com>
In-Reply-To: <25525e4dab6ebc49e233f21f7c29821223431647.1555093412.git.robin.murphy@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 12 Apr 2019 12:37:16 -0700
Message-ID: <CAPcyv4heZ7+2QuS2YXYsZcU9EOb87MDymfO8-+bLhbPgYQAYJw@mail.gmail.com>
Subject: Re: [PATCH RESEND 3/3] mm: introduce ARCH_HAS_PTE_DEVMAP
To: Robin Murphy <robin.murphy@arm.com>
Cc: Linux MM <linux-mm@kvack.org>, "Weiny, Ira" <ira.weiny@intel.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	"Oliver O'Halloran" <oohall@gmail.com>, X86 ML <x86@kernel.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	Anshuman Khandual <anshuman.khandual@arm.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 12:02 PM Robin Murphy <robin.murphy@arm.com> wrote:
>
> ARCH_HAS_ZONE_DEVICE is somewhat meaningless in itself, and combined
> with the long-out-of-date comment can lead to the impression than an
> architecture may just enable it (since __add_pages() now "comprehends
> device memory" for itself) and expect things to work.
>
> In practice, however, ZONE_DEVICE users have little chance of
> functioning correctly without __HAVE_ARCH_PTE_DEVMAP, so let's clean
> that up the same way as ARCH_HAS_PTE_SPECIAL and make it the proper
> dependency so the real situation is clearer.

Looks good to me.

Acked-by: Dan Williams <dan.j.williams@intel.com>

