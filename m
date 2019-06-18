Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC553C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:20:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3D11120B1F
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 04:20:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="DuLk3e8E"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3D11120B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 998928E0003; Tue, 18 Jun 2019 00:19:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FB358E0001; Tue, 18 Jun 2019 00:19:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 774EC8E0003; Tue, 18 Jun 2019 00:19:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 397078E0001
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 00:19:58 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id r142so8442791pfc.2
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:19:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=U0bgcwdCYh7A9L1+kJ/BXTzLGPDAuWCyNs3vhvtV0Pk=;
        b=bN0BWb8ypAdN3T6RFPq1WNdabilwEDfuAt0YW0j2GPoM9dcworxwxiYAgkW7T5W4He
         it6MymPKeFgZCmuPcso0zwNVPwRHRZ26G4vzn66/zPWSKy6eaHRyW4QnawhWxcupCxe2
         1mJcWMnXsBquUqNvEBfOq+Ug10lb5gDz9/RFD2V/oHRzeNlKW/wlNQGFlolVEzgpN6cw
         ZPa6mgZcrbdSxTGEKW25y22M5Lf6BZUeLPpBFkuGGqryDOH5DAZHHJUbNwl5oSbAAS5I
         swSrsznZWtnt3n7+jIkSh0KBD/A80kBusUy85V3ZFDiomq5RmGhfzj1iLTFdQTBNY7Nu
         GINA==
X-Gm-Message-State: APjAAAWFHGxgX8GT4t/vYzkgu0S/qq/mL95XKxc6TFQeE+STRraULrcX
	eW1dzhMbrURClrgXjxkwIunRYAfe73TFRtySzki6Nxcothi7m3ZhGWU4l9MQaJZ60ZuWxg/S6Lj
	iIgg92AWKgMgdf24vT18ZN2pmAwMA4mvSXteIYS6tPb2tj09qPnoYDM7p8H7uxksZOA==
X-Received: by 2002:a17:902:a412:: with SMTP id p18mr44478021plq.105.1560831597656;
        Mon, 17 Jun 2019 21:19:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw7n6e5RK1EKRxUb/kAGMSthZUvYnhVRbicEB4sPT/2ZVbodJ69pYMnji1ljeSIWN3SuVee
X-Received: by 2002:a17:902:a412:: with SMTP id p18mr44477978plq.105.1560831596842;
        Mon, 17 Jun 2019 21:19:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560831596; cv=none;
        d=google.com; s=arc-20160816;
        b=WmmISiU0joFGS1oH1h+/KogAiYqbJ7KHQ+luhIMeXNGnwX7OtGTvMPykyqF8EyK0Xt
         B5U0EcjBN+mWPfLzPmY0m6lQWOJW/X1DGbxMrKWi2bXMy2HO89BMALK3sBRGRip2V/ya
         BTvmdGVhtDKFt7QOhU+4B4f3DJAsubT1DZ8rEEFzfVLbeuA3HjssnB5x6fGyMxbRn0Ee
         BNTLgprk6oPzXOr0PjN+Rihjwvlsoh1kqoNYRcdyWUb/BKRV5PWM6wdsk4QS2p05Zu1p
         oNy19P/dQXMTxphAVJApi2uJyBIQ9c+xC7fZQ8kVrmPd46znX3BKmoJ6b1FCB2/wsNiU
         d0Jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=U0bgcwdCYh7A9L1+kJ/BXTzLGPDAuWCyNs3vhvtV0Pk=;
        b=oI/RVasAf3xR7u3VKWdwuzW0x+qX/wIfW3EOfiwlo8Og4n/+F+uWUTc7bWmf78NKUm
         ECMMiqXjKg+RorjVq1gjVNNv4TWq8E2GZXFP2TMER7kmzhifEG0CCUORIy1zR/9WFUrg
         ix7Imaa2PLXuWnr6Fj9Y3UDoyYV2Epi0W5pDYRItzvUhCp0dhB+u3+S+20wgTkFZco7M
         EE5KlZISnHPpkNQOmMAUKUOpD0KJsj8ULIkOU+84Ro+ulkqZnrfHTO/QqxvHTqga01tb
         6CFx5gtDdIPIL+//z3w4cV1aGR+IBppygI1oBtoOqr2CHQP+NEUC1X4X9G3VJeG7WF96
         jyeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DuLk3e8E;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b4si12778524pfg.49.2019.06.17.21.19.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 21:19:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=DuLk3e8E;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f43.google.com (mail-wr1-f43.google.com [209.85.221.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1C33F21734
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 04:19:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560831596;
	bh=51rZ9e9LkNVBLGHAIif1eIVHEBL3AZLf/1gX1DPTttU=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=DuLk3e8EkWUmqjbMfqOhBVznVeVo0ij+gX+dBj6X0D/RiqGPAyRXac3zAcRajl+NC
	 rG8dKjmVC7cMcg+ACN+3b4bthSfnYsFrxPjfTgqhyZKFcThYwI8P3UENip/XJE3+MM
	 sTMSBKCyqPy5UWo0Vh97re/7Sj11UC+1Gd22CCLk=
Received: by mail-wr1-f43.google.com with SMTP id p11so12289768wre.7
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 21:19:56 -0700 (PDT)
X-Received: by 2002:adf:a443:: with SMTP id e3mr26082705wra.221.1560831594613;
 Mon, 17 Jun 2019 21:19:54 -0700 (PDT)
MIME-Version: 1.0
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
 <20190508144422.13171-46-kirill.shutemov@linux.intel.com> <CALCETrVCdp4LyCasvGkc0+S6fvS+dna=_ytLdDPuD2xeAr5c-w@mail.gmail.com>
 <3c658cce-7b7e-7d45-59a0-e17dae986713@intel.com> <CALCETrUPSv4Xae3iO+2i_HecJLfx4mqFfmtfp+cwBdab8JUZrg@mail.gmail.com>
 <5cbfa2da-ba2e-ed91-d0e8-add67753fc12@intel.com> <1560815959.5187.57.camel@linux.intel.com>
 <cbbc6af7-36f8-a81f-48b1-2ad4eefc2417@amd.com> <CALCETrWq98--AgXXj=h1R70CiCWNncCThN2fEdxj2ZkedMw6=A@mail.gmail.com>
In-Reply-To: <CALCETrWq98--AgXXj=h1R70CiCWNncCThN2fEdxj2ZkedMw6=A@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 17 Jun 2019 21:19:42 -0700
X-Gmail-Original-Message-ID: <CALCETrWX877XD=mivftv96y00tWxT5THFD5MgoF+c_BPqc4aDQ@mail.gmail.com>
Message-ID: <CALCETrWX877XD=mivftv96y00tWxT5THFD5MgoF+c_BPqc4aDQ@mail.gmail.com>
Subject: Re: [PATCH, RFC 45/62] mm: Add the encrypt_mprotect() system call for MKTME
To: Andy Lutomirski <luto@kernel.org>
Cc: "Lendacky, Thomas" <Thomas.Lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, 
	Dave Hansen <dave.hansen@intel.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	"H. Peter Anvin" <hpa@zytor.com>, Borislav Petkov <bp@alien8.de>, Peter Zijlstra <peterz@infradead.org>, 
	David Howells <dhowells@redhat.com>, Kees Cook <keescook@chromium.org>, 
	Jacob Pan <jacob.jun.pan@linux.intel.com>, 
	Alison Schofield <alison.schofield@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	kvm list <kvm@vger.kernel.org>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 17, 2019 at 6:40 PM Andy Lutomirski <luto@kernel.org> wrote:
>
> On Mon, Jun 17, 2019 at 6:34 PM Lendacky, Thomas
> <Thomas.Lendacky@amd.com> wrote:
> >
> > On 6/17/19 6:59 PM, Kai Huang wrote:
> > > On Mon, 2019-06-17 at 11:27 -0700, Dave Hansen wrote:
>
> > >
> > > And yes from my reading (better to have AMD guys to confirm) SEV guest uses anonymous memory, but it
> > > also pins all guest memory (by calling GUP from KVM -- SEV specifically introduced 2 KVM ioctls for
> > > this purpose), since SEV architecturally cannot support swapping, migraiton of SEV-encrypted guest
> > > memory, because SME/SEV also uses physical address as "tweak", and there's no way that kernel can
> > > get or use SEV-guest's memory encryption key. In order to swap/migrate SEV-guest memory, we need SGX
> > > EPC eviction/reload similar thing, which SEV doesn't have today.
> >
> > Yes, all the guest memory is currently pinned by calling GUP when creating
> > an SEV guest.
>
> Ick.
>
> What happens if QEMU tries to read the memory?  Does it just see
> ciphertext?  Is cache coherency lost if QEMU writes it?

I should add: is the current interface that SEV uses actually good, or
should the kernel try to do something differently?  I've spent exactly
zero time looking at SEV APIs or at how QEMU manages its memory.

