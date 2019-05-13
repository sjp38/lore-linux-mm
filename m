Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4078AC04AB1
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:46:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3EEE21883
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 15:46:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Os4/hJwW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3EEE21883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88F3D6B027C; Mon, 13 May 2019 11:46:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 841ED6B027D; Mon, 13 May 2019 11:46:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72E1B6B027E; Mon, 13 May 2019 11:46:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA1F6B027C
	for <linux-mm@kvack.org>; Mon, 13 May 2019 11:46:00 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m35so9433052pgl.6
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:46:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=edBsAXcW3OU/rYt6NCkyRDSH54O9XLHeGVnSJB3b3Fw=;
        b=OAKTsLRvZSuVWkzJ6yExkpvG83keO/ztnld/x6zsu+xNOSkN3zNN6wvz+CbbW0jNKm
         NBE59uXwA9/azmaQyTJV5USyMV+Q/7aQddLccXjslR+wiZdIMLZbfElkPy2qvDEE114g
         66tXeXVmoxqqm5buuETHsrSMy5OdU9JUVDRFbTuVPjwX36nG20Fxrm6sz/dnx3XTu+Q7
         8YgXEpCXrp9eHDXBwCnCiEmCzJa08UuF+Z4eaXELr3FMBv0+rM+UJ7rT9qf3AaSsw90O
         70pUf2DQK3zo0Qh3awfEmsvvWCgMkQDEW4jOih2CvmsCqV3KoPIOxu+HaAv6Xa8D+rJw
         myFA==
X-Gm-Message-State: APjAAAUWS9CT8ms/0DHRM4aX/ejQuVZTXNid5/ly2LPxwUBlN9TCAXCd
	UVtV3R8/+VsxV9LxQBrb1ikBdiykK0tA4DrkUhBr/fzLRVfgLmsRlOJ3XHNqNFFDSa05SpGv+MX
	S1yLMrZ0fupd/mcE6jSQzQD0J64SS84JFDPdCD6uEHCEOrnG9VUQAF1oO64S66eFI1Q==
X-Received: by 2002:a17:902:2808:: with SMTP id e8mr4878466plb.244.1557762359863;
        Mon, 13 May 2019 08:45:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxW7ODsvbZfHwD45L1bLH8vH7Rq4kO2fb2p/fxt8FeIX1DahCmucaOhy4wsu+Wl2A+UDkIs
X-Received: by 2002:a17:902:2808:: with SMTP id e8mr4878368plb.244.1557762359041;
        Mon, 13 May 2019 08:45:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557762359; cv=none;
        d=google.com; s=arc-20160816;
        b=TVjOPplTXe+WJMfbH9/CEl2JkapIt1ut1okgH8e15DxUFU5/Lmdm7UWudVOS4qnjTF
         UXi0VjGrohuHiAU0Hmr0fSzfB7zmjp/NJMHiYcw5wJ2lES9n/JLY6XEca/1UBk8c3nB1
         wYCF9xPW+lacmX3nPmzIUQtEfC9pYrFJGf9ewFqNFChjIDmvm09Iuqwi4Wfn+krN76y4
         ehO9wpFCZHoR3aVNJsML2sKjACKiycZE7nmtoSRm10Sj3XwSgIOwlLgf3HKdJG7eQ0CE
         aXJkdZ7ZHNMInP8X2OO0QzMsdMK2hROI4wZqpb1izmLSADInjtD2CswWxBrEFrtzuHWF
         VPwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=edBsAXcW3OU/rYt6NCkyRDSH54O9XLHeGVnSJB3b3Fw=;
        b=09QeA0izpQ4Hw1l6BgBQW3uCLM2S+9R57e2YpCGgjb8uscOSsoZSyr1S1l+4MaM49b
         bDvmEVSRcbwzngcDYqs6+sNFxFRQQYqwS4cHz36eygjgnZgTIS+hrYD+755pkwcH5lP4
         pgyQObzokDIr1SPE30IiiADL8VvZyBAMOWmrThuG1+ANGZvbCpBrn1pvbaLNUi/LHmpw
         d2FPyGewf6xRl+PPv8HdJEAXsd2uY1yB/2Mwkkjd1qbqjFl29lLPx5zntfqGwhSSx+Oj
         9mNKUXbz5rcoDlvhhCSRaHaCziP+88oFrBbxvUPJXV0kn0bWxj9jVdz5ThgKyVcpWy54
         CebQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Os4/hJwW";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b6si17894430pgk.279.2019.05.13.08.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 08:45:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Os4/hJwW";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4C94C21537
	for <linux-mm@kvack.org>; Mon, 13 May 2019 15:45:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557762358;
	bh=BABeuTSqBcwBR4EDIoxeTc9kWB/TDj6EfW9QIQhsYNY=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=Os4/hJwWSkAdbGceMgGRjKFt8j+/6lOvqEBDCCCNQBIVuwuamTCRkhBSqlKoOIc3B
	 bKg4d8F9EV+vF3Ma9/80M5RXduvPhjC/zADKDy9UjeOXh0Lpprw9DYBC66fJ2hbnW8
	 5AX19NgZ7HW2pLeO0tk2CRUtry4EHPrNeSrw6c9k=
Received: by mail-wr1-f42.google.com with SMTP id w12so15874685wrp.2
        for <linux-mm@kvack.org>; Mon, 13 May 2019 08:45:58 -0700 (PDT)
X-Received: by 2002:a5d:45c7:: with SMTP id b7mr5830508wrs.176.1557762356875;
 Mon, 13 May 2019 08:45:56 -0700 (PDT)
MIME-Version: 1.0
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com> <1557758315-12667-4-git-send-email-alexandre.chartre@oracle.com>
In-Reply-To: <1557758315-12667-4-git-send-email-alexandre.chartre@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 13 May 2019 08:45:44 -0700
X-Gmail-Original-Message-ID: <CALCETrV9-VAMS2K3pmkqM--pr0AYcb38ASETvwsZ5YhLtLq-9w@mail.gmail.com>
Message-ID: <CALCETrV9-VAMS2K3pmkqM--pr0AYcb38ASETvwsZ5YhLtLq-9w@mail.gmail.com>
Subject: Re: [RFC KVM 03/27] KVM: x86: Introduce KVM separate virtual address space
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
> Create a separate mm for KVM that will be active when KVM #VMExit
> handlers run. Up until the point which we architectully need to
> access host (or other VM) sensitive data.
>
> This patch just create kvm_mm but never makes it active yet.
> This will be done by next commits.

NAK to this whole pile of code.  KVM is not so special that it can
duplicate core infrastructure like this.  Use copy_init_mm() or
improve it as needed.

--Andy

