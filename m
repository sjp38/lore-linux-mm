Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D56CC282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9656F2082E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 23:00:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GnZmV+ME"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9656F2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FBCD8E0064; Mon,  4 Feb 2019 18:00:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D0ED8E001C; Mon,  4 Feb 2019 18:00:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F02A28E0064; Mon,  4 Feb 2019 18:00:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF2E18E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 18:00:23 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l76so1063321pfg.1
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 15:00:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=kH0IHrJSoQFyAx4iofM5iGBNHAzEokQMp3CgcnSLWMU=;
        b=iN0QEMJiixOFdrQ+zW/1Q1GP4/frarKDapVATQFjU0pYSnwK/UnSjvEBlBZan7lhiH
         gS8wi9DLRBqA/w5zsgcqVk097xFuU9bVjSdI85KuPpBBtVzehDz8G1hjfpo9HlMmEDfZ
         C0AxLdJ1Yjk51lle1W8AVSuh6FT8SfLu1I3SpfUfZI0V+kMtBmL4/qXKfjfyVyUmXrSG
         JhGn/bNgak57pGgsw5CfLWIIM7TCpe4MihBYWcs9ihpYz8MfhTTuaLsu4bVx9NdSD6Ka
         VCWAbRnipv+P9hBrLoag/ak/R5h/aI9q8crrrCZuOvcXtOZ5n+tu+G2/bHAfuqVTO1is
         omTw==
X-Gm-Message-State: AHQUAuZAcUKFytJTdg4xFPSs0dGn39xgtwKGrYFM0tVPxulnFMmfSmSD
	tT7bJbB8HFlFOzwcMKOT3+24Nep3OqQbLpiffK+U4uVt4ZrnAFaC3fviJcY4Yv/41hGoXJS0hQ+
	5JHPncFP62FOEA/8HxFJheyvAtFiSUyzcG6AyHAaEDuXBRbyt46iTGVGo5XA3IyDwaO01bWUdEG
	yIETUWcWq/mRB1g5M6s/AielJuuYl6yxV0MN0x7ImIWBLfUew0jEenazkf4QffOBNsI6aXSfcrs
	E/rG394bVnO+9+qNPQaulWALl7OFzr1CTe+VRVZJyRXEnQgwDacLBMJHXEdvehM1IZHqoqc9MTx
	MLFHFBfX7F2adkaFHpIDZareHC7i9Moty79Bnm0LOAcKw1+MG4HIvRRLbzu0b/0J247va4E1UZ3
	G
X-Received: by 2002:a62:1d8f:: with SMTP id d137mr1767480pfd.11.1549321223261;
        Mon, 04 Feb 2019 15:00:23 -0800 (PST)
X-Received: by 2002:a62:1d8f:: with SMTP id d137mr1767397pfd.11.1549321222333;
        Mon, 04 Feb 2019 15:00:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549321222; cv=none;
        d=google.com; s=arc-20160816;
        b=zGaqZwQCkJn92CHGMTXdyiFxsgr3h3tFPJc88YNIwJsgQdoCVYfkuKBAPo6aKEY3uY
         q0LsfCPTQSKbZIWWxlEF5hNZEwmBn+ITMx3RMVOd0vPMsu0nYFTxYTp4zIs1CLLz0c1O
         nOFFDfQ2O3fN76NlS0M8rY53XPqk4SyTBEUO8/ZYTH/4sqav0BTz5Z7lH+cKDvaGDdKU
         MqM4ZC7mmFWG59j8PoiwOGPPyMv5BJVG83j7HNMrOkWx7BiqTdDFDmPqhNMftMYLKmm0
         R1VenUFSX01siIvIwbzEku1Jbd+d+/03sFMyApVHRMfdFm9sRMHoMxwz4FFpeMy66Kul
         7K2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=kH0IHrJSoQFyAx4iofM5iGBNHAzEokQMp3CgcnSLWMU=;
        b=NA3trYwRk1ABrZsnnJxLdp/GLEdh0YO7J03iuY23plmIYpR9ZhFn905uUJUQHhg8TY
         oerIlu78qK4i8KzUhE8yqdKQuLQEn8TwXEnnO8B3axgtn12uZ2pdB72G75X6L1AOrJQX
         kYuy4MqGFJ0SEhuaUXg/+xXt5jgOKeCuZHKwbR3vAQNDhqrfGj47MpPt4mwF6Drwe3Ca
         J7Y7rHG2t56tZAWteYQ48CXESZPq/D9kqdR5+55wliF1LiDO0i3fX+HhyUsX82i5Px1F
         aKKVj1d/h2Udjzy9DNaI755QZ8OvYgJnnJRdg+JCj7ry90wA67+pwK+wythJ1+5l1k2a
         rutw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GnZmV+ME;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s68sor2400856pfk.40.2019.02.04.15.00.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 15:00:22 -0800 (PST)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=GnZmV+ME;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=kH0IHrJSoQFyAx4iofM5iGBNHAzEokQMp3CgcnSLWMU=;
        b=GnZmV+MEm33hkAkY9eB1nN1X3/jXo/QLCfEDhSJHU8vzSX1HEogQumQfMPy7HPxobt
         T+aXfqW8AFccomMTEPS6w8U7z/QcF3pLVNJ5o18VlhjMLaxIW4hh67KUXdGfX2hld2uA
         YbgK+lOK7MkPlmhe9On64hl1wtmvQgt0A0xOrTP/WOPA6U9ShU++WofSNfFfldPvhRGp
         GkI4vrJ3suckIBPSHSiBgWqfUVn5DMulWpeEuhs/SwVOx2HF8HkjtrCBKyZ3CFLyZBoJ
         PjDVle8X6etbJLIULNived/+VwIgGz9z/NiXGw8mInO8NvfUxIlnbP5tdVMg0ZnSPW76
         /cvA==
X-Google-Smtp-Source: AHgI3IbxieJuU8CAP3+p4ZFwdqqvo1bB729g6OoR3vk4fJ4zW7+3UdY/IEHwMwKmNkmuVu4fxAp8ZA==
X-Received: by 2002:a62:cf02:: with SMTP id b2mr1802977pfg.183.1549321221419;
        Mon, 04 Feb 2019 15:00:21 -0800 (PST)
Received: from [10.33.115.182] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id u70sm1579632pfa.176.2019.02.04.15.00.19
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 15:00:20 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190204181552.12095.46287.stgit@localhost.localdomain>
Date: Mon, 4 Feb 2019 15:00:18 -0800
Cc: Linux-MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 kvm list <kvm@vger.kernel.org>,
 Radim Krcmar <rkrcmar@redhat.com>,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 X86 ML <x86@kernel.org>,
 Ingo Molnar <mingo@redhat.com>,
 bp@alien8.de,
 hpa@zytor.com,
 pbonzini@redhat.com,
 tglx@linutronix.de,
 akpm@linux-foundation.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <4E64E8CA-6741-47DF-87DE-88D01B01B15D@gmail.com>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181552.12095.46287.stgit@localhost.localdomain>
To: Alexander Duyck <alexander.duyck@gmail.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Feb 4, 2019, at 10:15 AM, Alexander Duyck =
<alexander.duyck@gmail.com> wrote:
>=20
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>=20
> Add guest support for providing free memory hints to the KVM =
hypervisor for
> freed pages huge TLB size or larger. I am restricting the size to
> huge TLB order and larger because the hypercalls are too expensive to =
be
> performing one per 4K page. Using the huge TLB order became the =
obvious
> choice for the order to use as it allows us to avoid fragmentation of =
higher
> order memory on the host.
>=20
> I have limited the functionality so that it doesn't work when page
> poisoning is enabled. I did this because a write to the page after =
doing an
> MADV_DONTNEED would effectively negate the hint, so it would be =
wasting
> cycles to do so.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
> arch/x86/include/asm/page.h |   13 +++++++++++++
> arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
> 2 files changed, 36 insertions(+)
>=20
> diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
> index 7555b48803a8..4487ad7a3385 100644
> --- a/arch/x86/include/asm/page.h
> +++ b/arch/x86/include/asm/page.h
> @@ -18,6 +18,19 @@
>=20
> struct page;
>=20
> +#ifdef CONFIG_KVM_GUEST
> +#include <linux/jump_label.h>
> +extern struct static_key_false pv_free_page_hint_enabled;
> +
> +#define HAVE_ARCH_FREE_PAGE
> +void __arch_free_page(struct page *page, unsigned int order);
> +static inline void arch_free_page(struct page *page, unsigned int =
order)
> +{
> +	if (static_branch_unlikely(&pv_free_page_hint_enabled))
> +		__arch_free_page(page, order);
> +}
> +#endif

This patch and the following one assume that only KVM should be able to =
hook
to these events. I do not think it is appropriate for __arch_free_page() =
to
effectively mean =E2=80=9Ckvm_guest_free_page()=E2=80=9D.

Is it possible to use the paravirt infrastructure for this feature,
similarly to other PV features? It is not the best infrastructure, but =
at least
it is hypervisor-neutral.

