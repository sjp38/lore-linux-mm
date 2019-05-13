Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AFF0C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5214721473
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:49:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="rp9du5MO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5214721473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF48E6B0005; Mon, 13 May 2019 11:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA5BE6B0008; Mon, 13 May 2019 11:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D93A46B027E; Mon, 13 May 2019 11:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5FB6B0005
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:49:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id f7so3807565plm.15
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:49:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XCFW2567l4uQbqfc/zUYfmUqYDzBJxGpqdyPIiW/FkY=;
        b=LZ+qDoeJ93S5LQarxybPFIWShgQw+KNvmy+H+FoVf5nfiDUj1Utc82n6DPzv2KsIoZ
         K2LNkU9l5sbv7T7vQ4R9C2PaNtIz5E1hgAGS751kz0ecenyIZJllVakG0LhgL+L1uejw
         FposloWk9hSeqFECaOknXt1HwZUDQsmFZSSj392r8U6i/n/l/RtENETLwSKAzwTjKGmf
         H9XmRkCtXFcS45BdMnyXmk7QyIT5ydBRjX2aBQ6zd0rbJmk1zEb12iswmhamtvBzJDvk
         UsHEsam2uEIb462pespqJfqVCjRk5z9+FZEgoEJgtPWZ/NNagMkIC2IurWfs2gGxd1ZG
         jGWw==
X-Gm-Message-State: APjAAAX98ngHRxrcK5ABl1xxY+tRCQwio9Cq7ZtPwUeLTFFwEM99R/0G
	9QsOqucp+nkWhnoj2f31Zza6et73hDQo1hGjxGJbiV3PWrpX8BYNHZjsRuRYhBgVXzBnQCISkt1
	r9fwV37j52Yy9K4oHskRjNPCn0X116zH/CBvCI945p1MwAi51VavazMK8SD42ESaOwg==
X-Received: by 2002:a62:ac0c:: with SMTP id v12mr33891005pfe.59.1557762561313;
        Mon, 13 May 2019 08:49:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw63xfenB0fOlrI4/kVw0xypC2H207hF+3M/QtM+Fexi+KnicZxIsjK7Q8ejBByv/Dt09/U
X-Received: by 2002:a62:ac0c:: with SMTP id v12mr33890912pfe.59.1557762560641;
        Mon, 13 May 2019 08:49:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557762560; cv=none;
        d=google.com; s=arc-20160816;
        b=hyY3meE1o356aIai16Wk6Ewzj7/l1le8+/ew/QsoPDNGJE1XQsiWtxQGn5+12+ya1w
         V+3PwdZg8c7JjjRatu9SvP9JsAARZd+90b7bD3FDGg+WsxVxKPXVPxAlHZLeMW5Es6J8
         K5rotx4uFGNJhzGwb3E3RLEjAbXsiBRQA0jHAaT4NgOwW/+SHXY2ZmoYKeqSo9EnKbB6
         lfTXcRx0o1XB8c4SefLCO9aeTLfQvrmJ9CXXld5z5qh6Ks6dqRykB6JJLsTb24U6CwJp
         FhHbD5Mn8Jaz+KTVZ/aTTth/l3K9PrSfklQtf/HzLl+x8RBy7oEPFBRGFcoAwSljDvhr
         yLDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XCFW2567l4uQbqfc/zUYfmUqYDzBJxGpqdyPIiW/FkY=;
        b=wB4TLHEEhCTXqx05lQeU/p4nlNZwsMqVttlm2MTcaYbTcW1Lel4GrQOaOGfoh6MokQ
         ItHzguSC2irgtX20lMxfIXpB1q997rKR8a5vTEC5zRgTT0dOLDeM8DZcDeHMTCMhpWUx
         eaGMgRdyavufgB+fxXwKy17W7BUtLQw1+Pc78xlmlKk4uzlFRwvqgP0oL1L919+6AbMx
         axrqE5BkqFtK9VmUUceXXLg90g0PZ7u/37zEHyPonGYDr3B+ulU9Vn4Mn+V3tByAqBGW
         fqhmnpIxI+0mZyWajVOIsioQVa3Dh/EWLWoTJ3aC0NigCXaJ9DjCupHCat5NzYHxWm1x
         eAZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rp9du5MO;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l22si15683995pgc.523.2019.05.13.08.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:49:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=rp9du5MO;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 151F521707
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:49:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557762560;
	bh=iu0DvAJjkMh0MqQjI1Y4OdDJERot1b1WNhATGWADuGY=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=rp9du5MO21nSayjZvEV1P+McQzueie510+aXWIwZDusr/NFBMwc8rezLPKhgqr32X
	 3bpPFK2yS1j9w8/gk2ZvrdLIpltbrgs5fP6MQ8XfN0XLNE6B/el429ftLpgsiSQPsv
	 LdGX/qAGGgoG1klNvY2ITJvDZvWta9cbZAHn6heo=
Received: by mail-wm1-f43.google.com with SMTP id 7so8202948wmo.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:49:20 -0700 (PDT)
X-Received: by 2002:a1c:486:: with SMTP id 128mr15280833wme.83.1557762558612;
 Mon, 13 May 2019 08:49:18 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-6-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-6-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 08:49:07 -0700
X-Gmail-Original-Message-ID: <CALCETrXmHHjfa3tX2fxec_o165NB0qFBAG3q5i4BaKV==t7F2Q@mail.gmail.com>
Message-ID: <CALCETrXmHHjfa3tX2fxec_o165NB0qFBAG3q5i4BaKV==t7F2Q@mail.gmail.com>
Subject: Re: [RFC KVM 05/27] KVM: x86: Add handler to exit kvm isolation
To: Alexandre Chartre <alexandre.chartre@oracle.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Radim Krcmar <rkrcmar@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andrew Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, kvm list <kvm@vger.kernel.org>, 
	X86 ML <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, jan.setjeeilers@oracle.com, 
	Liran Alon <liran.alon@oracle.com>, Jonathan Adams <jwadams@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 7:39 AM Alexandre Chartre
<alexandre.chartre@oracle.com> wrote:
>
> From: Liran Alon <liran.alon@oracle.com>
>
> Interrupt handlers will need this handler to switch from
> the KVM address space back to the kernel address space
> on their prelog.

This patch doesn't appear to do anything at all.  What am I missing?

