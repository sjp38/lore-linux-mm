Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADF55C31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:07:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 634E02084D
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 15:07:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="I/ApQtMU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 634E02084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0EF158E0005; Mon, 17 Jun 2019 11:07:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079418E0001; Mon, 17 Jun 2019 11:07:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5B4E8E0005; Mon, 17 Jun 2019 11:07:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A7FD58E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:07:43 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x9so7198893pfm.16
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:07:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=APZnbT8xfzibFZO4quG3uKS1bevo3QXYzsqYmxbMAb0=;
        b=jFvRW7cKXbMNxh4QkzRqhd8beyRoYrAi003gVJaYtxIU/LGzi9cJCHhuOwLZUyfrY0
         2fVV1uo+MSJ76JtHz/Ow++IpirlCMNNLauOroVTZcQ7KDEW2bRuKMU+kiuRrsrynNWXs
         UcJxv6y/7pENeBMvJAourZtvGyQ/N4ZsZT2dHu7BeuIOQ6J7PATcJkmhAncXwtypt2+W
         U9ow57dxq8xNydLPSR9+YAQ+qVsNsRFyb/iaezkta2WfBPmlATSm53X/spaSMXbPDOW5
         Zij6WQMFMNH35rF7/z2tIBrgX8ie559t7K1XtUJcKte/YlOzuxgfUbAjINzQ7tdCGHJn
         AJEw==
X-Gm-Message-State: APjAAAX6IbN3pYAp0/SptZ5OA9EtJnHr60KL9VW/en3A/ZsiCQN2ad3j
	SCHjkArj8v79QM3fN+AAPJ26BjtkYyQVm63ycvj3rsaDmOMv8Ue4Xjj31Iiq3hg+aEby8xsZ3mI
	ISgPlyFsW0waPWtf9CZs8tB4DyLC7ehWa626iF+/dl60wXndQOSEe7JZWDcI41wKIgg==
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr26846792pjw.85.1560784063286;
        Mon, 17 Jun 2019 08:07:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIcapkvECIe8j+OwS73TW+HHKxhj7KvAt4DoG0HeQoHdMForj2HqvEHXRL5QVlPfa6I2GE
X-Received: by 2002:a17:90a:d14a:: with SMTP id t10mr26846723pjw.85.1560784062411;
        Mon, 17 Jun 2019 08:07:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560784062; cv=none;
        d=google.com; s=arc-20160816;
        b=bighgF7vKL/APoNgGHq1boNyYaGGtqeDHNrJ5AkzRPtjRqmiwwxE3E65CnPZe6CLnY
         bKrh2KJadUNjhY6A7D3YJq39QMQ7LbbVV34yUOizpF1BalB+1UYvH/XioFxOcOCpWQ5A
         FIWN9ZSJjBXMHCVzhz5x5WuEjuiuwkhhy23MJKQQAEp0RlKkX9OwxzDjN0Bb7jM96rbV
         eleOr996Y32T5oo5TEUtd8oCaysf4mGqmuX9v9m3fHFt32DO/Dji8gW/cag0iFrCDdF2
         PfntCWspj5UOd61ALzNgSI4+haFbtqujx543O9YbXjX5fsgAFzytDlwCNjfFOGVrNVy8
         F+6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=APZnbT8xfzibFZO4quG3uKS1bevo3QXYzsqYmxbMAb0=;
        b=CH0CTzcXuP8G1J2iGw3jzByfRsVZfAPtK0mrh4F99BcihgF3etFEVBNTCpMIZiL8mC
         MyyykHgEKjdnroA84N/2Rdy0DxnDnRpHI59tVtpKpof9c7t9ww2AT3uJ+6a6HQnHSj8A
         QD6kvS+/kzhxi9L+pvh5np7EkvuE1lpX5q2pUEr7K2tIr+waFL8uzbsE7Nh0v/Bayumw
         F+Sa/h54RbFndmFNAr7LRLvRWxqFWDicMpvYhTpuoyJtG1Vgln0FKUsz2FERRsshFNl/
         UoZgfeHesDMeEweEosoN0+DDrL6i1k7yBypcPfqigpBXpJkma6EwojTb41vJWPdOylX5
         A+bQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="I/ApQtMU";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z3si10523156plb.384.2019.06.17.08.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 08:07:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="I/ApQtMU";
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A7BE62084D
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 15:07:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560784061;
	bh=Gxoxo21Lfkn/K7A7njUdmGutlMuh89H9AmOUNy6D3vQ=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=I/ApQtMU2c7Erq76ulOQfmcrDmnpDEXaOss+cIh8d1xkuPl7032CvSXOL9EZfy+bX
	 kN+OzpEl6FGyha8+h3QOshBAdHDM66xHhHaCbLuHvpcBGjYWpqCxLUD+Mu0ZmDhBri
	 IrSj8qhxRg5bEr9Xvc4ayTQFsDJvfBu5r46IUcrE=
Received: by mail-wr1-f41.google.com with SMTP id d18so10374596wrs.5
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 08:07:41 -0700 (PDT)
X-Received: by 2002:a5d:6a42:: with SMTP id t2mr12131692wrw.352.1560784060277;
 Mon, 17 Jun 2019 08:07:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com> <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
In-Reply-To: <20190508144422.13171-46-kirill.shutemov@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 08:07:29 -0700
X-Gmail-Original-Message-ID: <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
Message-ID: <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, 
	Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>, 
	Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, 
	Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, 
	Alison Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	kvm list <kvm@vger.kernel.org>, keyrings@vger.kernel.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 8, 2019 at 7:44 AM Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> From: Alison Schofield <alison.schofield@intel.com>
>
> Implement memory encryption for MKTME (Multi-Key Total Memory
> Encryption) with a new system call that is an extension of the
> legacy mprotect() system call.
>
> In encrypt_mprotect the caller must pass a handle to a previously
> allocated and programmed MKTME encryption key. The key can be
> obtained through the kernel key service type "mktme". The caller
> must have KEY_NEED_VIEW permission on the key.
>
> MKTME places an additional restriction on the protected data:
> The length of the data must be page aligned. This is in addition
> to the existing mprotect restriction that the addr must be page
> aligned.

I still find it bizarre that this is conflated with mprotect().

I also remain entirely unconvinced that MKTME on anonymous memory is
useful in the long run.  There will inevitably be all kinds of fancy
new CPU features that make the underlying MKTME mechanisms much more
useful.  For example, some way to bind a key to a VM, or a way to
*sanely* encrypt persistent memory.  By making this thing a syscall
that does more than just MKTME, you're adding combinatorial complexity
(you forget pkey!) and you're tying other functionality (change of
protection) to this likely-to-be-deprecated interface.

This is part of why I much prefer the idea of making this style of
MKTME a driver or some other non-intrusive interface.  Then, once
everyone gets tired of it, the driver can just get turned off with no
side effects.

--Andy

