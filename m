Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01352C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:41:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94CC1217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:41:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="QVWUihYI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94CC1217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 422786B0005; Thu, 18 Apr 2019 00:41:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A8866B0006; Thu, 18 Apr 2019 00:41:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24BFD6B0007; Thu, 18 Apr 2019 00:41:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D95B96B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 00:41:49 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e19so638921pfd.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:41:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HEJvVD5uAri2/7g+yjiM7+uD6Xn5OUBCfeb7aIYw4eQ=;
        b=PwcXi2pv1TCeGRJb263dyek21SevZjbVKts5n6TfKKg3zeSt9I50xlAfKVSsiNDEhq
         D9jvt+9nS9WSyrs+sqHx17Y9zHlsRjbfn2g5a5R5YVejuF44bfJwLV8Xs05fmoMOvuZ2
         v90HEnEexl699t4SEFy0SrXM7TE/6Ad89iJaQmxY3LeCw2VhoGXJw7JE+vl0IWvvvphQ
         YYhP6PZ1KbHaX8Y5iYlxIMmB7zIK00JyOgKTz+eGW1fyDJfTG/td6dMI16+mIQh+FKUN
         zVidJ9IZlYXjuGvxzPHJy3RX+C1GeMy8zQIqD0If46lSViWtoo34BIxSNkXF/PGN1kGa
         +F0A==
X-Gm-Message-State: APjAAAVOg8+wEoyhe2jQTV6n9FpM57GJ/xIVyyhucMOZ9kUYBEvJ/o7x
	jNM8LBfSAX7tSIXYHx4jK8e/HgyZil8nYwbdqhJ98Yi/P2UT3/seCRQFDyF9KYG1nWVDDHWAlVl
	dyd+FwajCRWVfGXDWh0Emg8xH+RrjfsTTf+Y07FkJrQWFv6h3vA78zKF9x6v6JPCXYA==
X-Received: by 2002:a62:7549:: with SMTP id q70mr83582123pfc.112.1555562509431;
        Wed, 17 Apr 2019 21:41:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJ9hAeU3pr/nZjJuSCuilg1MaTL58gojLULZr3U5r9W2/ltL65WoyhcoFeFIbBzdW3Hqr8
X-Received: by 2002:a62:7549:: with SMTP id q70mr83582081pfc.112.1555562508564;
        Wed, 17 Apr 2019 21:41:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555562508; cv=none;
        d=google.com; s=arc-20160816;
        b=yS1oGJ30U3E5dNIYABlOKNdTNfH6uziLJhnGIfjk2RK6A1zg5CD/OI3ih5RrxDLDkK
         RSnFLREn3Zft0SPM2ykHReVKMnneNB+gvBZw6oB6D70m+Tva3pF5RI+OiYUn+pj1JIOz
         6mLzaE0xLv+bWIMZFckXgugiMEmdMdzuYw4/tGOXOgZ4mNP42iORhwf7xybnjd0sSv8a
         hPpERfIkv4yFV1A/nhpa+TGJUX9Ug9wJoQ7VTj0gJYGkvi1YiOgAb7urrxjKFxEQgFt0
         okngbkqBSDuoDa/jYz7CxJeAzUbfhRk000djWJJi9Y6c9Zl8cJLoTMOOdfe4JMGH488/
         z8hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HEJvVD5uAri2/7g+yjiM7+uD6Xn5OUBCfeb7aIYw4eQ=;
        b=IZMcVeMYM5HZie9gjPSDX4vRZk3ya53CmpG3hIiwVEdiBhTJvjdp/7Ofh7jQw6YiGI
         F/S//mdKmB61ZS1he3E3xiY2uWt5L8jLTK56/EdOCLP9DHDCqQt15VOYwDf+ASAB2KXY
         5SoHGLI9btzjePvX/q1ElUMGg3PaPAM8bjTWv/HPw8AUqOPOUftpZbTqUxr4a1Wpzvme
         R0f98+ocHpHnAdMIBPFJG/acEJQJ59I0wCa0xOfYp1WRXjYXLrG++1xsIalqIvV5gg5g
         pFNA5GJfhsB2pXWb3y0G1bcU95sOUu4L25KOLvVLoGwGbckeCKuRdJPdLWkShrWr2ccv
         pL+g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=QVWUihYI;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x23si1028909plr.48.2019.04.17.21.41.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 21:41:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=QVWUihYI;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f46.google.com (mail-wr1-f46.google.com [209.85.221.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 01C89218EA
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 04:41:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555562508;
	bh=ZzJFjyGToYfbKAC7a2m7yS86J4A8OLDkslCG6xa8cQM=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=QVWUihYIOED3b6sf++tgY3iRdj8kiMHZVbckG4nNfCAClSFzLnTcPH+IgFSB9PrKC
	 Z2tMpLhiQqQpdAO8Vqghyo+PaFXtDr9TPVxG3ICymGFgejmh9f9/1/nnjg3BTRsxMd
	 IElW3sPpwA7MwJfgB7BILSJAa6MZxHiR0qJmXz6w=
Received: by mail-wr1-f46.google.com with SMTP id w16so1173366wrl.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:41:47 -0700 (PDT)
X-Received: by 2002:adf:efc1:: with SMTP id i1mr59073183wrp.199.1555562504832;
 Wed, 17 Apr 2019 21:41:44 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com> <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
 <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de> <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
In-Reply-To: <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 17 Apr 2019 21:41:33 -0700
X-Gmail-Original-Message-ID: <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
Message-ID: <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, 
	Ingo Molnar <mingo@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
	Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, 
	Kees Cook <keescook@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
	Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	David Woodhouse <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>, 
	"linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, Khalid Aziz <khalid@gonehiking.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 5:00 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Wed, Apr 17, 2019 at 4:42 PM Thomas Gleixner <tglx@linutronix.de> wrote:
> >
> > On Wed, 17 Apr 2019, Linus Torvalds wrote:
> >
> > > With SMEP, user space pages are always NX.
> >
> > We talk past each other. The user space page in the ring3 valid virtual
> > address space (non negative) is of course protected by SMEP.
> >
> > The attack utilizes the kernel linear mapping of the physical
> > memory. I.e. user space address 0x43210 has a kernel equivalent at
> > 0xfxxxxxxxxxx. So if the attack manages to trick the kernel to that valid
> > kernel address and that is mapped X --> game over. SMEP does not help
> > there.
>
> Oh, agreed.
>
> But that would simply be a kernel bug. We should only map kernel pages
> executable when we have kernel code in them, and we should certainly
> not allow those pages to be mapped writably in user space.
>
> That kind of "executable in kernel, writable in user" would be a
> horrendous and major bug.
>
> So i think it's a non-issue.
>
> > From the top of my head I'd say this is a non issue as those kernel address
> > space mappings _should_ be NX, but we got bitten by _should_ in the past:)
>
> I do agree that bugs can happen, obviously, and we might have missed something.
>
> But in the context of XPFO, I would argue (*very* strongly) that the
> likelihood of the above kind of bug is absolutely *miniscule* compared
> to the likelihood that we'd have something wrong in the software
> implementation of XPFO.
>
> So if the argument is "we might have bugs in software", then I think
> that's an argument _against_ XPFO rather than for it.
>

I don't think this type of NX goof was ever the argument for XPFO.
The main argument I've heard is that a malicious user program writes a
ROP payload into user memory (regular anonymous user memory) and then
gets the kernel to erroneously set RSP (*not* RIP) to point there.

I find this argument fairly weak for a couple reasons.  First, if
we're worried about this, let's do in-kernel CFI, not XPFO, to
mitigate it.  Second, I don't see why the exact same attack can't be
done using, say, page cache, and unless I'm missing something, XPFO
doesn't protect page cache.  Or network buffers, or pipe buffers, etc.

