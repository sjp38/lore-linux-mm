Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B17AC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:18:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 445342085A
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 18:18:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VJfYnS+5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 445342085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9A446B0008; Mon, 13 May 2019 14:18:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4B8E6B000A; Mon, 13 May 2019 14:18:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3AE66B000C; Mon, 13 May 2019 14:18:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C54C6B0008
	for <linux-mm@kvack.org>; Mon, 13 May 2019 14:18:55 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b69so1896279plb.9
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:18:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=E9lLDpiAybp5oI5DGq5XRxoJEmZNLZXtN8BwGUOu470=;
        b=Z7cjwuCYDnarvaLXrAijVqhUiU+rAAxekjfXvuINmGHaquHEobCANgHQ6IDt3Huwng
         ITSrySPHRIIUaWSxOVxnBemrHSmYAEYUkPvpRrnI06CuUNnHh7LsoXReQlZvYv94DxU6
         iPXDHooYV293e04szfd87swb7t6Ec9vtocQSO/cIyqwGxfVJP5tjNF3PRwLhJqK/AdrH
         WA++6YLDrFeLoPYFXEbGJcvVM/Ib+ywh103uSlC1/JXfK+wlytHmd6uM+BFp1ZcKIRw2
         ytsw79WruyHKBq5lqKaXyc0t1w3IBn+wcxPphIPqteyoDnIGj1itgd3o4ZD+/etc7gh8
         KI2Q==
X-Gm-Message-State: APjAAAXMsLNwzcR+xEXl/MS2Y+mYxA5IWX3xcwC01/erGNo56KWUpL3b
	NiwQLVJ2SpN9/9AQ/byDjVKhQcyokQsGiZjKur+Sq5vIwQbmdhT5ez20n/eoKIvcXN7Ky/QvKLW
	nbQL3zm6jd9j9x3bYO5oomngVKPRcIYp0Mg8bIt/XxCR2Tb+ADHx5VUhovF4rTspohg==
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr34813487pff.104.1557771535249;
        Mon, 13 May 2019 11:18:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9lhY5JV5pJPCwEfJmdbweT4M0uyMvLbaCWkmKujniLakteeuTby45Kj9zHJ4uuBAJgCkq
X-Received: by 2002:aa7:93bb:: with SMTP id x27mr34813417pff.104.1557771534650;
        Mon, 13 May 2019 11:18:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557771534; cv=none;
        d=google.com; s=arc-20160816;
        b=BcwAhr4ezn4Gbb4hBFL8jCvdPdjoF1+QYgD767VG3gSc+j/y6oJIsFRUkf0BnBrZ1x
         UdDUhyDZwDCLXeZEQlZLxujRRWzu8TQDUy0VpHKmnBhPCaG4HUsL3P/Rn1c/kSnI/1Hh
         e1OehhTb6q478nTP8gkI/Vk1BZZmMN7RvWPInKL79O8nQmC58wQlXera/VSQ61HNq1CJ
         3N4if3SLJT2uaC7zFrgsgDhFvPSpzdOFjDlzNnPkTrbYB0rpG+uOzgXisL43iMPxUSRV
         40YT8uafDVlxEoAePRpMCwe9lUx5ERF3mAe0dlHk4V29UNrVVLPvUSTChB7z3Y+ux1Qc
         AuWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=E9lLDpiAybp5oI5DGq5XRxoJEmZNLZXtN8BwGUOu470=;
        b=T6HGt6GCxUyADPR85sojBXDhR20DYZniQ9wFKClVYpZ8HgqPedbAHv1X2nEuCF69VB
         ksLtLR3hPPY/SxHmUol0GWmxTIi8paDY5hSDMuE1hfqtyhv7Ms9X7fiLZh7nrIeBTUVK
         i1wO2XHp1pL3N9RQ6yw8z61k842XAck45FxUsnewcgAXV9bpEdoR3/Cjv8CyLijnFgdD
         5bRGwT7TLOT0YVWf3lEK/VEEzgo75mFqty8I7shXBKZl3+/BwvnC4wQiht/fJf8TgDTl
         +WMgp0yK4xBr58kEi7nr71I/FV4/CUurjfbBX8RT6SVHDtQ+qJgHJYKmU+7I4vi46ndR
         uExg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VJfYnS+5;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q125si3552728pfq.163.2019.05.13.11.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 11:18:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VJfYnS+5;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 131F2216B7
	for <linux-mm@kvack.org>; Mon, 13 May 2019 18:18:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557771534;
	bh=0D70YYCaYJ/0FfOh4xzmgNQF/8UOkldQ6uPFbgG5pwI=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=VJfYnS+5yGbxOPZ/IrGIvPvGQ3MWsey8Zcw2ynEdyFK0bMhb6EA9kn+qh0dub8jNy
	 BUnM34hwwZ1Svmkf5b+KeyY5QW3SWsWXC0ncGsSlKjnU7m5z/A5Z5cT9X6y3liCLay
	 edErDf2BS2T6yENCy2PLIQTWiBRyIZLCTwIbQJ9Q=
Received: by mail-wr1-f41.google.com with SMTP id o4so16390173wra.3
        for <linux-mm@kvack.org>; Mon, 13 May 2019 11:18:54 -0700 (PDT)
X-Received: by 2002:adf:ec42:: with SMTP id w2mr17777817wrn.77.1557771532684;
 Mon, 13 May 2019 11:18:52 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-19-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 11:18:41 -0700
X-Gmail-Original-Message-ID: <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
Message-ID: <CALCETrWUKZv=wdcnYjLrHDakamMBrJv48wp2XBxZsEmzuearRQ@mail.gmail.com>
Subject: Re: [RFC KVM 18/27] kvm/isolation: function to copy page table
 entries for percpu buffer
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
> pcpu_base_addr is already mapped to the KVM address space, but this
> represents the first percpu chunk. To access a per-cpu buffer not
> allocated in the first chunk, add a function which maps all cpu
> buffers corresponding to that per-cpu buffer.
>
> Also add function to clear page table entries for a percpu buffer.
>

This needs some kind of clarification so that readers can tell whether
you're trying to map all percpu memory or just map a specific
variable.  In either case, you're making a dubious assumption that
percpu memory contains no secrets.

