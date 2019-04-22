Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D138C10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 22:23:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0F6E205F4
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 22:23:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Vl0fYQ0U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0F6E205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BDD56B0003; Mon, 22 Apr 2019 18:23:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494746B0006; Mon, 22 Apr 2019 18:23:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 384586B0007; Mon, 22 Apr 2019 18:23:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 129106B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 18:23:47 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id v4so6211904vka.10
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 15:23:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Apsh13b43ex5kM603MFVFBzVRJeAAR6IMS53yCHVuRM=;
        b=GshvWUUYvJRxhfj9bc43ASNJXUfJLoOBzFWzqep+U6AoJfPuV7T3RSuuXv/ilWPJFy
         17KZYBdV05OoNH0PQ30nSIVAieRpFUbG+DoTgtm6aouPsAy1GgqrE3DchYOvNjKjYc1b
         4U5EmCLSqWaKbGOZyZuUoNe5grrwrzne8ok9Od9c3aY/9sJS5MfdKucnuPJRGIET21Ag
         bL1/FH93GpC6/+IsPbDrTDrajo2krQkh5YsUOuHtXDH4BUqqZAdF0k5KzbFWNwZP5rBO
         0HJaJ7r+SgCyYGHlh824xT10Bp8Cgs8mHQTbR0LezmMb0qdjxx3s1epBhbaQJTy6NdqS
         WOXw==
X-Gm-Message-State: APjAAAVqkwMmMPh9qv9jp+N8hWn2rhzCapUSxNB/HdTfrqUNXPlObNJB
	k4SkdmG80n6CKeSjCaDNELHwcxBvjEmQAYKBWZAXGcsK8v0oYxjEgIvOMOnNnSYXEQR/R5uw0eU
	RIMFDEpSZkgc2mZizbgdfxiptHFcDorXN6MV7geYX/ziq1sify4NFXR9Fk7kjKuhfBQ==
X-Received: by 2002:a1f:28d7:: with SMTP id o206mr10861685vko.36.1555971826737;
        Mon, 22 Apr 2019 15:23:46 -0700 (PDT)
X-Received: by 2002:a1f:28d7:: with SMTP id o206mr10861661vko.36.1555971825654;
        Mon, 22 Apr 2019 15:23:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555971825; cv=none;
        d=google.com; s=arc-20160816;
        b=GIHj4eqMsxUW8NlRpIPgrpudYln9rbcDi6ydzLofTF4HBSODj3RliXmR2DP3My9GYr
         QFRV5ShIXJfJCLlj7Rsjq5Eqv/eQZMbx3G4FcKAPI+Sa4/XgUisK0O8ddfus7L95zPo+
         Qb6SVrZmDAsyFe89s36Ughlrw6p5D+EiOYIQFs/bIyer8K+AMF+IMEAfKp9YDFNHiac+
         tTKmTDTtl7XMUrpZChjnOeTINQ9mefJKUsj7vkbIgm6HcpSC5gQ7Ye1adrqd4g5aY1mi
         GySG2uRQfzLOuZXCbwa17WYV2YvdJaK/NM0NWLRVc1aXYI7OvzcVUJrZxT33Q6/S5ZMB
         ciCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Apsh13b43ex5kM603MFVFBzVRJeAAR6IMS53yCHVuRM=;
        b=ry3oGFmLEfjh/8wSooxsIexK1rhyZ4CY0Sjjwp5/8MsSfQkbxRuPhZyRNSSmUC9GON
         YcqQKGv0YE44ItHBpOdVYpAB2VNPfJ1rLzn+jT6mw059O4DzPgfEECOZI1Ag7g4chC9G
         Ex7Q5qR0gZnz+xy8V+42tf4HbcSWDSW/x1BphP+oeyZPQ1vPoPpWSqDIjvsYRzg5aUOZ
         BRKunjTnGEtbadN5rcddC/UJbpBa4ccYGcOyBUKVW0/9IvJx4OfSYqRH30J0k2jB48U9
         IpIRxDNFFvNjAwda7q2J4eTW+6JKcyr7D83IjJI8YOSonBOZjdE2GTroEs1jXS09ewnC
         LhIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Vl0fYQ0U;
       spf=pass (google.com: domain of keescook@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l70sor954965vke.12.2019.04.22.15.23.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Apr 2019 15:23:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Vl0fYQ0U;
       spf=pass (google.com: domain of keescook@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Apsh13b43ex5kM603MFVFBzVRJeAAR6IMS53yCHVuRM=;
        b=Vl0fYQ0UCHGtndl0jafErZw5vqbDAq4DrFX3SfBAIMhEhneL9rXawPTcud8fgV5g3D
         W/sHE49ARVD9KYD5FloU01n2RfA2pTgnKMthR4SE5EVifhT+Zv7f89iMoQqyLkH17UHR
         Ufjeoo3iZe8A1ywqY/dQX9OJ6hQY+RdFMicuSiIFmS2kjW0kxDgF0PQchZJoFDeQwLJ4
         Bu9iNZw8/m1h5Vvq6bsIi0oFDRabTh4fUKE/VXZ1BpEeHCWZiVc862ytrlz+nAaTR+Cp
         kF/vZydc6r2yg2X0nSiZbBoPzLhOuIzzabOzb88ffPr/VLLo66HUZNIe7JxAbYTKUz7T
         O38g==
X-Google-Smtp-Source: APXvYqxiq50qJu8wanUuH+yOCTaJNMUpHEhGXVEwCujnFscJAmlLegU3s6VeZj+61I7iVGG+tUCCywSMlxsTtse/mUo=
X-Received: by 2002:a1f:2e07:: with SMTP id u7mr11692664vku.44.1555971825052;
 Mon, 22 Apr 2019 15:23:45 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com> <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
 <20190417172632.GA95485@gmail.com> <063753CC-5D83-4789-B594-019048DE22D9@gmail.com>
 <alpine.DEB.2.21.1904172317460.3174@nanos.tec.linutronix.de>
 <CAHk-=wgBMg9P-nYQR2pS0XwVdikPCBqLsMFqR9nk=wSmAd4_5g@mail.gmail.com>
 <alpine.DEB.2.21.1904180129000.3174@nanos.tec.linutronix.de>
 <CAHk-=whUwOjFW6RjHVM8kNOv1QVLJuHj2Dda0=mpLPdJ1UyatQ@mail.gmail.com>
 <CALCETrXm9PuUTEEmzA8bQJmg=PHC_2XSywECittVhXbMJS1rSA@mail.gmail.com>
 <CAGXu5jL-qJtW7eH8S2yhqciE+J+FWz8HHzTrGJTgVUbd55n6dQ@mail.gmail.com> <8f9d059d-e720-cd24-faa6-45493fc012e0@oracle.com>
In-Reply-To: <8f9d059d-e720-cd24-faa6-45493fc012e0@oracle.com>
From: Kees Cook <keescook@google.com>
Date: Mon, 22 Apr 2019 15:23:32 -0700
Message-ID: <CAGXu5jLPkD_6BL1m2=13KVTfZ7znr-xAyz+CB23eoeboFgCSOg@mail.gmail.com>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Nadav Amit <nadav.amit@gmail.com>, 
	Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, 
	Julian Stecklina <jsteckli@amazon.de>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
	Juerg Haefliger <juerg.haefliger@canonical.com>, deepa.srinivasan@oracle.com, 
	chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, 
	David Woodhouse <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, 
	Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, 
	iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>, 
	"linux-alpha@vger.kernel.org" <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	LSM List <linux-security-module@vger.kernel.org>, Khalid Aziz <khalid@gonehiking.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, 
	Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Arjan van de Ven <arjan@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 7:35 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> On 4/17/19 11:41 PM, Kees Cook wrote:
> > On Wed, Apr 17, 2019 at 11:41 PM Andy Lutomirski <luto@kernel.org> wrote:
> >> I don't think this type of NX goof was ever the argument for XPFO.
> >> The main argument I've heard is that a malicious user program writes a
> >> ROP payload into user memory (regular anonymous user memory) and then
> >> gets the kernel to erroneously set RSP (*not* RIP) to point there.
> >
> > Well, more than just ROP. Any of the various attack primitives. The NX
> > stuff is about moving RIP: SMEP-bypassing. But there is still basic
> > SMAP-bypassing for putting a malicious structure in userspace and
> > having the kernel access it via the linear mapping, etc.
> >
> >> I find this argument fairly weak for a couple reasons.  First, if
> >> we're worried about this, let's do in-kernel CFI, not XPFO, to
> >
> > CFI is getting much closer. Getting the kernel happy under Clang, LTO,
> > and CFI is under active development. (It's functional for arm64
> > already, and pieces have been getting upstreamed.)
> >
>
> CFI theoretically offers protection with fairly low overhead. I have not
> played much with CFI in clang. I agree with Linus that probability of
> bugs in XPFO implementation itself is a cause of concern. If CFI in
> Clang can provide us the same level of protection as XPFO does, I
> wouldn't want to push for an expensive change like XPFO.
>
> If Clang/CFI can't get us there for extended period of time, does it
> make sense to continue to poke at XPFO?

Well, I think CFI will certainly vastly narrow the execution paths
available to an attacker, but what I continue to see XPFO useful for
is stopping attacks that need to locate something in memory. (i.e. not
ret2dir but, like, read2dir.) It's arguable that such attacks would
just use heap, stack, etc to hold such things, but the linear map
remains relatively easy to find/target. But I agree: the protection is
getting more and more narrow (especially with CFI coming down the
pipe), and if it's still a 28% hit, that's not going to be tenable for
anyone but the truly paranoid. :)

All that said, there isn't a very good backward-edge CFI protection
(i.e. ROP defense) on x86 in Clang. The forward-edge looks decent, but
requires LTO, etc. My point is there is still a long path to gaining
CFI in upstream.

-- 
Kees Cook

