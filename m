Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0A5FC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:02:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0C4920840
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 20:02:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="xFoEutrN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0C4920840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3F24E8E0003; Thu,  7 Mar 2019 15:02:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39E318E0002; Thu,  7 Mar 2019 15:02:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28FC78E0003; Thu,  7 Mar 2019 15:02:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D93FB8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 15:02:28 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id z24so19063331pfn.7
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 12:02:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pivgfEq4mhqsEYUZWM9t1+3S08n60PCVcM2AvOOaPKU=;
        b=p05Bfkt01LLX4clF62JqVf4LofwAbTcdBqL1UIJB2YEQkccWjtqI7Ey9ZdOfJIu+hc
         x6uz0dhvZQQd4a/KCcPkVYi+yD9gorbJfWbbBMWL7wRlVn54iTAWGs7P/do/ulkweirI
         pVW+TIJwsq1xKy68R+E4TdPLeTeIE1+dpFJr+ovNe9F07/ho6F33Cff85Pmy91Z57ms6
         hAGODmbL6ibk/zj52l0zbyXvUQ92efYYsRFKkbyuIfieVFq0WUjlLknQcSSEr7O6LgV+
         g90yTzlDNuWzmh8BkTFWg/FQ4as3eGB3QhNcPSUJvvw0wA43nPRQ9NIMBAK0wZS69Bu+
         qeZQ==
X-Gm-Message-State: APjAAAWaxdNDNxZbQBm5E373ODHOeE/uSv1P1qaCB+4cXv/JNhy+tuK8
	EFgfwIV9NY0DcuVXUF+R/PKsVAv1PbrbQ4bxvhEk3Cn5tjhyL29yLffRInmgJVRi2vA9soGKWBW
	vrE78NOpGLCB/DBd1pAd0Dmo1KVrhBlujfwztPe1ATiH8PdclpPrqmqLEaGtxeVPS2g==
X-Received: by 2002:a65:5108:: with SMTP id f8mr12928706pgq.441.1551988948463;
        Thu, 07 Mar 2019 12:02:28 -0800 (PST)
X-Google-Smtp-Source: APXvYqymWveiL1DiiIgWPGpEUKQj/DY5pKVe2q/IaJFWqUbbpy8sJork0VfdOguj+ZImmTTk4s7R
X-Received: by 2002:a65:5108:: with SMTP id f8mr12928630pgq.441.1551988947439;
        Thu, 07 Mar 2019 12:02:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551988947; cv=none;
        d=google.com; s=arc-20160816;
        b=PaeiQv6yOezhh6aofGgiXqSqjdvtBeOkb02zrkdC9qowxWnEDuSM8tLNx3mDUn9Acq
         Qp35XqYJ+ZbVmdL/qhGd1vKYIWEuBho4BtgX70wlHjb8xnztsB2W/y+OJZZEwnp9SOyB
         UCLcmcq4irulzBwSBOAY5vM2FGCYCIYkx+zpAZFp3ztODWH2v53PRbTIi2Hi6Pj791I1
         QufotW8uMmouUjJirA6uQry4k9mXLIvbg2qheOK8egUJsELqZVSX6pwJQ2U9vgz9tmp/
         PPtMuGbnL4IMTgXuA3euwfky2crR+0g3VneGCGho9BfyRtGHGE9fGuYBtSblNGLOTqUN
         mJMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pivgfEq4mhqsEYUZWM9t1+3S08n60PCVcM2AvOOaPKU=;
        b=FpRlt4/Hbq78yWCb0orH+t4X1ST/rEAim0GgB8dc25B3MYtFX7wThVFa5O+97zPYJ3
         H+3TQbeDxtPFVFcJm5Er3C2QBG/Bo0Xw3lwLUQ4igC9rXvhoNvf7dJvRdDhaAZtdvuE3
         gYMYvbBAbJ2tReD4rXqcAYVPSiK+RQRFpFoXMlkRwAExgUgoj3R8cioFnLstPvB5RwVs
         TVAUGk6YDet75FjkGyvnQo6jku2vsgRnRyQ66BsL1C8JWdJxqj5QrEPEt4Y/Fwk7lR8j
         hsqlpn55dtOxYdmYxQRQ2DhruLeYMdGw7OPl+answTsTB+KO91ucTbt7eobJLrjV/t19
         tY/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xFoEutrN;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x123si5206936pfx.135.2019.03.07.12.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 12:02:27 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=xFoEutrN;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A3A34214AE
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 20:02:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551988946;
	bh=ByUaQCKcKzv0my0lmiYVV9zvCyXBm/O9YGbgtfnaDvo=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=xFoEutrNCFxsAXsya3vogmMws26zcLEAwg4QKEwGfg302hvBR5x8P8KhU5hhI7Os1
	 W7L6Mvh+QJyqBsPYmM68NRMz70jOCahmrkVkadRznFi6uqXGUi0IHZg8he44i3sBV7
	 S8bV2bmuWt6lpF99SLDvot59MBDqvi8WGFoBKHhA=
Received: by mail-wr1-f48.google.com with SMTP id t18so18938178wrx.2
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 12:02:26 -0800 (PST)
X-Received: by 2002:adf:e58f:: with SMTP id l15mr7917047wrm.309.1551988945061;
 Thu, 07 Mar 2019 12:02:25 -0800 (PST)
MIME-Version: 1.0
References: <20190129003422.9328-11-rick.p.edgecombe@intel.com>
 <20190211182956.GN19618@zn.tnic> <1533F2BB-2284-499B-9912-6D74D0B87BC1@gmail.com>
 <20190211190108.GP19618@zn.tnic> <A671F14F-3E03-4A97-9F54-426533077E0C@gmail.com>
 <20190211191059.GR19618@zn.tnic> <3996E3F9-92D2-4561-84E9-68B43AC60F43@gmail.com>
 <20190211194251.GS19618@zn.tnic> <20190307072947.GA26566@zn.tnic>
 <EF5F87D9-EA7B-4F92-81C4-329A89EEADFA@zytor.com> <20190307170629.GG26566@zn.tnic>
In-Reply-To: <20190307170629.GG26566@zn.tnic>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Mar 2019 12:02:13 -0800
X-Gmail-Original-Message-ID: <CALCETrUY6L_Fwd9CZzo2eZL8HT2sBSHFiD-Bp-HCPPFBxkzcdA@mail.gmail.com>
Message-ID: <CALCETrUY6L_Fwd9CZzo2eZL8HT2sBSHFiD-Bp-HCPPFBxkzcdA@mail.gmail.com>
Subject: Re: [PATCH v2 10/20] x86: avoid W^X being broken during modules loading
To: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Rick Edgecombe <rick.p.edgecombe@intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Damian Tometzki <linux_dti@icloud.com>, 
	linux-integrity <linux-integrity@vger.kernel.org>, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, 
	Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, "Dock, Deneen T" <deneen.t.dock@intel.com>, 
	Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@intel.com>, 
	Masami Hiramatsu <mhiramat@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 9:06 AM Borislav Petkov <bp@alien8.de> wrote:
>
> On Thu, Mar 07, 2019 at 08:53:34AM -0800, hpa@zytor.com wrote:
> > If we *do*, what is the issue here? Although boot_cpu_has() isn't
> > slow (it should in general be possible to reduce to one testb
> > instruction followed by a conditional jump) it seems that "avoiding an
> > alternatives slot" *should* be a *very* weak reason, and seems to me
> > to look like papering over some other problem.
>
> Forget the current thread: this is simply trying to document when to use
> static_cpu_has() and when to use boot_cpu_has(). I get asked about it at
> least once a month.
>
> And then it is replacing clear slow paths using static_cpu_has() with
> boot_cpu_has() because there's purely no need to patch there. And having
> a RIP-relative MOV and a JMP is good enough for slow paths.
>

Should we maybe rename these functions?  static_cpu_has() is at least
reasonably obvious.  But cpu_feature_enabled() is different for
reasons I've never understood, and boot_cpu_has() is IMO terribly
named.  It's not about the boot cpu -- it's about doing the same thing
but with less bloat and less performance.

(And can we maybe collapse cpu_feature_enabled() and static_cpu_has()
into the same function?)

--Andy

