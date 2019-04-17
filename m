Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D5ABC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10B56205C9
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 19:49:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="bkgqQKeu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10B56205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6DAD6B000A; Wed, 17 Apr 2019 15:49:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9F4516B000D; Wed, 17 Apr 2019 15:49:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BDDF6B000E; Wed, 17 Apr 2019 15:49:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF226B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:49:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 18so15239093pgx.11
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:49:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=iE6ZxezbsAnxY7b8623590Y49+KIRCSBYNr9ucJ9cPI=;
        b=JWeI9Z4AFHMBU4+GvdEe1XMP4O3EFIIVaS3qgZeyDBzWaTJREfr12QhzRODlgKwlOA
         DB8K50LDskt43duwEFC0irA9kGsM8AYjXeHGpJ9u6cNZljjJ48C+hi49zbNWUNWwCf15
         5eeFvMNdUpRpY3emSYaMgdyDaM3QxPlth3+u5lHI/BirdJDe4KLFgNQKzkoSpgoRaWgY
         +kq+dV4q/UQumklrujIR5j2Zkcb6+3UKbv2R18IXVkd3D2IqNEA99zudIe1QY5juvqNl
         Pet1V+oUDaJhvBnzwP+5Wp2XzpZQLVFlPuDVt1mqq0R+GJXqST4AkjgA1cwy0P7gC+mx
         Y0Zw==
X-Gm-Message-State: APjAAAVgGKBSblPywXBk5R6Hzf3/pDCam7A4K0i6SxkB6SWvxxhrNeD3
	1cb9rb3Egkjh/LCzax92JeuQ4dkgHo5h06qw9C9VTvhg0pNs5NO4Yjhgt7ZozDIb1Ne75UxQkys
	izeJdbWxewAWYWxqCBsxLg+xeRHivthKlFwFCe94jYWZX8xjQSvQBs24XMbR5Hh+HMg==
X-Received: by 2002:a62:305:: with SMTP id 5mr90806413pfd.65.1555530560952;
        Wed, 17 Apr 2019 12:49:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw35cJkmC4dy1dusnotoXhM/nXt5HZbfvQKmkBaAi+wYRt68CvEudd+da16gjQuIUGagpyH
X-Received: by 2002:a62:305:: with SMTP id 5mr90806360pfd.65.1555530559995;
        Wed, 17 Apr 2019 12:49:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555530559; cv=none;
        d=google.com; s=arc-20160816;
        b=MvvYQnBRYSMv2rxLomlkXiCyVdGOUxvp7zQtuOrKK1h66y67aYxJfouMMhOU4eSVDS
         Ta0Xzsn0dtvtEadkzuiFZoh8RdpF8yEH3T1OrjDXodjcArS9rA0uYZuer8+Fd0bcBr0q
         eeaI+1cdwXGjCSTFMXNiAdBJ69uXna7yulkRVks3tdXHLY9AHbLDcfJ1wJPdoyN4vEN5
         bxeVtGs8KKObeiKtRMHY6ZqGvYtWhR/RQjXeGV8NI5qd5hBRWqtuwGE3QF8Twck/0B+X
         nSIxQ9SNbChBk8oDQQ6oGrK43opi6n5UnA7Xl72A+h1sv2b8L8l/C5JVeDfCgHkn4Tsw
         M3Rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=iE6ZxezbsAnxY7b8623590Y49+KIRCSBYNr9ucJ9cPI=;
        b=CTnVIjuvZanADo5wgtHPhEzib0Qi+vmpefSUW1Ebo7gOoLaToUzYEY8PHsqn1pjU2g
         f7jegv1EsjdN1wtOhvRlgSmrqVSOIinNajQIld++smCcRgnY5bZXB7wZARSsHKyt6W1r
         XioDI6bT0YfyrYZVWL9YJ8TaCuedcTqx/wOYN5zMNzv/bHm1mus0SCBI64+oicTlRtEy
         Pb1Z4OyIinlADCgxsLh8uNC593IkpmN+7zg1miePH00H0tOXqwHB/64nc8S/7VocBByy
         6D5SzNBrAdXEWnBzVwjP4rBZYqmDufq0yu4gWrkaVp55EZL4vFjN0ZbvOPZzQ1utpIgY
         BsdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bkgqQKeu;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 34si24825830plf.288.2019.04.17.12.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 12:49:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=bkgqQKeu;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 61D20205C9
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:49:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555530559;
	bh=un9JngdqTRaqtIrvykfJj/MFL9SGLhvcacMgNjMe4H4=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=bkgqQKeudwW/ql7cXAWlWd7+w2wYtPSx6J91uUy4ZcxjeDA+8lal1Pkj/qr69xaG/
	 WaXdLduXEkACl++4dtx/SX7Zph9S7Ix/sxHMbDFm88OskSxAWn3IEKh+NRXMidwD3K
	 9T8r8nGq3B3hHgBGtMaf10n4GQfaCrB4rbSIaRJ0=
Received: by mail-wr1-f51.google.com with SMTP id k11so33517336wro.5
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 12:49:19 -0700 (PDT)
X-Received: by 2002:adf:f344:: with SMTP id e4mr23917370wrp.77.1555530556240;
 Wed, 17 Apr 2019 12:49:16 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1554248001.git.khalid.aziz@oracle.com> <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com> <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com> <8d314750-251c-7e6a-7002-5df2462ada6b@oracle.com>
In-Reply-To: <8d314750-251c-7e6a-7002-5df2462ada6b@oracle.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 17 Apr 2019 12:49:04 -0700
X-Gmail-Original-Message-ID: <CALCETrXFzWFMrV-zDa4QFjB=4WnC9RZmorBko65dLGhymDpeQw@mail.gmail.com>
Message-ID: <CALCETrXFzWFMrV-zDa4QFjB=4WnC9RZmorBko65dLGhymDpeQw@mail.gmail.com>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, 
	jsteckli@amazon.de, Kees Cook <keescook@google.com>, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, 
	deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, 
	Tyler Hicks <tyhicks@canonical.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, 
	Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
	Boris Ostrovsky <boris.ostrovsky@oracle.com>, iommu@lists.linux-foundation.org, 
	X86 ML <x86@kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, LSM List <linux-security-module@vger.kernel.org>, 
	Khalid Aziz <khalid@gonehiking.org>, Linus Torvalds <torvalds@linux-foundation.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>, 
	Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Arjan van de Ven <arjan@infradead.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 10:33 AM Khalid Aziz <khalid.aziz@oracle.com> wrote:
>
> On 4/17/19 11:09 AM, Ingo Molnar wrote:
> >
> > * Khalid Aziz <khalid.aziz@oracle.com> wrote:
> >
> >>> I.e. the original motivation of the XPFO patches was to prevent execution
> >>> of direct kernel mappings. Is this motivation still present if those
> >>> mappings are non-executable?
> >>>
> >>> (Sorry if this has been asked and answered in previous discussions.)
> >>
> >> Hi Ingo,
> >>
> >> That is a good question. Because of the cost of XPFO, we have to be very
> >> sure we need this protection. The paper from Vasileios, Michalis and
> >> Angelos - <http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf>,
> >> does go into how ret2dir attacks can bypass SMAP/SMEP in sections 6.1
> >> and 6.2.
> >
> > So it would be nice if you could generally summarize external arguments
> > when defending a patchset, instead of me having to dig through a PDF
> > which not only causes me to spend time that you probably already spent
> > reading that PDF, but I might also interpret it incorrectly. ;-)
>
> Sorry, you are right. Even though that paper explains it well, a summary
> is always useful.
>
> >
> > The PDF you cited says this:
> >
> >   "Unfortunately, as shown in Table 1, the W^X prop-erty is not enforced
> >    in many platforms, including x86-64.  In our example, the content of
> >    user address 0xBEEF000 is also accessible through kernel address
> >    0xFFFF87FF9F080000 as plain, executable code."
> >
> > Is this actually true of modern x86-64 kernels? We've locked down W^X
> > protections in general.
> >
> > I.e. this conclusion:
> >
> >   "Therefore, by simply overwriting kfptr with 0xFFFF87FF9F080000 and
> >    triggering the kernel to dereference it, an attacker can directly
> >    execute shell code with kernel privileges."
> >
> > ... appears to be predicated on imperfect W^X protections on the x86-64
> > kernel.
> >
> > Do such holes exist on the latest x86-64 kernel? If yes, is there a
> > reason to believe that these W^X holes cannot be fixed, or that any fix
> > would be more expensive than XPFO?
>
> Even if physmap is not executable, return-oriented programming (ROP) can
> still be used to launch an attack. Instead of placing executable code at
> user address 0xBEEF000, attacker can place an ROP payload there. kfptr
> is then overwritten to point to a stack-pivoting gadget. Using the
> physmap address aliasing, the ROP payload becomes kernel-mode stack. The
> execution can then be hijacked upon execution of ret instruction. This
> is a gist of the subsection titled "Non-executable physmap" under
> section 6.2 and it looked convincing enough to me. If you have a
> different take on this, I am very interested in your point of view.

My issue with all this is that XPFO is really very expensive.  I think
that, if we're going to seriously consider upstreaming expensive
exploit mitigations like this, we should consider others first, in
particular CFI techniques.  grsecurity's RAP would be a great start.
I also proposed using a gcc plugin (or upstream gcc feature) to add
some instrumentation to any code that pops RSP to verify that the
resulting (unsigned) change in RSP is between 0 and THREAD_SIZE bytes.
This will make ROP quite a bit harder.

