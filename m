Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 007A2C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A2EB2087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 15:03:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XHlgJWUe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A2EB2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CBF88E000F; Mon, 25 Feb 2019 10:03:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 354C58E000B; Mon, 25 Feb 2019 10:03:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 244C28E000F; Mon, 25 Feb 2019 10:03:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBE978E000B
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 10:03:15 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id f125so4087937oib.4
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 07:03:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JwnbB+HBTo5JOYnPid93hiHgo2MFCSC5v/rN5mqU928=;
        b=YnwfWN6pDL7ZU3KcuQoKQUZXWAZA/jAQawsE2u/WzGq9FZavIKZaj10bVHu9+WM/iU
         V/mqOJ6nZUHRaR8v7higG31b7XEXvQsz4hfchWYwLpOS+YyRaJkRSTIi4F1XOnoeTs/e
         oBZ4xC4LdN2ptAH8pL5W+mHLWs144lG2FaLv6cZpyLO1NE0o4ZKWzLV6C0KmqVIiNSRW
         49Yy1wfwQr/a/yX6U/+9fNtwjyhUlMapvSlSF99R2ZEPvBVD4v7mo6XQa/Pz3CsIaeb8
         LB73arv+gFcyyvVuGXIfVYR4s6tFZZu8nlz0P9ayu3NLAV164p28bFo9fy5ZmMGIMRtp
         GmrQ==
X-Gm-Message-State: AHQUAub5br4EeRA2DNd/BOe/bSGSmPlT35ZNlGnDI9v2y4ys9Mj5gBp2
	3iGRYryma4kxmME68z0PB/ETJDGFhC7X4pOEABN0SgmyVRdvXbLgE1mg2a9eFvVdPFW3rdFm6t0
	x+EDDJebDS1foLPRX4C1CR/kpU/N858iXdfcqKrGmwzZ85kLlvECpqohbfiGF6BqloWa422w0wa
	HnCVDNq97Vkm08Z2bKAaT070nEiTOFoLPpmkwkx5J7ULgtGXn7GuHXH/cw3OQtqIGl5W4Oiutvr
	1P77zr9qAxnoUTJM7nl3vCdjEQUAwLVGGlTYguAimL1gERRx16kLTvz8tRR+BmmS0zDKUmcm0se
	prWSFxiCnAlltpVmtTFiYc+NaSMz2T49LYbWV7zVWJw0q+zUGNu61hjl1ZbcRRLqwVgeMBLUXf/
	m
X-Received: by 2002:a9d:7cd3:: with SMTP id r19mr12331427otn.139.1551106995660;
        Mon, 25 Feb 2019 07:03:15 -0800 (PST)
X-Received: by 2002:a9d:7cd3:: with SMTP id r19mr12331367otn.139.1551106994732;
        Mon, 25 Feb 2019 07:03:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551106994; cv=none;
        d=google.com; s=arc-20160816;
        b=tpnPgv1cFTf15XVwfXITsCouHInWYUWceVZ511TWH+q+GPb541YBThYrXENoDUleNq
         YK3lKDQWtdrOXGmKkSKKXiMjOH1tK9ul+xeE7XLJgBbD8UGWisrTf+sUc5ow7kSbILFs
         AMDPfIYjNkrxcxgYSwdEc3m2LBbu9Vs9cv2xUVYlKh1amxxpz9JTR0zbugBKoOn62FLS
         W+h+7BM2dGFB/YW8MoCgG+ObE/EOawWMILSDLZWUxP6Uy0gC+H0FvAedeQvduPdJSIfk
         BoKIQpBq85DeBCP52tyLL1fZfTAxr49k2JitumH4a0av/90Qokn1Odg/ZDIGgMG20qxW
         a/9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JwnbB+HBTo5JOYnPid93hiHgo2MFCSC5v/rN5mqU928=;
        b=yFOsY2o3aZSDkXwNihWe2Zdf6jdPG6nIevscy4Khiy3z9QL8JtmB4c90t2CkogVrfH
         t4DjJM4+Hd9mXTVmQvJqhROU3q1fTP3dP6kUCHDSOJ22mKtR6q5jF9qZAZO01N49lBc3
         B+tDU+i2kd+w6quQAJ2yhM3wRwSkr5Zu8TaAkIfX9D33WC0+eFEH5XCgcdDzyAQXInnG
         TtuoSWphP0pWKx3SvOJBvgW5bTw3eMV4aeUACa9FyGWefD3+VGHwezNHrWbs+gJ4ZWSW
         hO6r26FXvl2tAo9cAY/6ygmW4SapiMfLp+swu0nzk1PJ0XdMLYLDm01PC5Rkbcu1mpgq
         wF9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XHlgJWUe;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u6sor5579198oig.6.2019.02.25.07.03.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 07:03:14 -0800 (PST)
Received-SPF: pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XHlgJWUe;
       spf=pass (google.com: domain of jannh@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jannh@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JwnbB+HBTo5JOYnPid93hiHgo2MFCSC5v/rN5mqU928=;
        b=XHlgJWUeDDx6lbpgfLUpQ5yfIUQFGfn1m5PPc7WGIHxyFHF+3HA8RToeR0IuWQTMN/
         kYElrj1fN+IeqNdYbRmwAUaB69TMayM5wuJbTEp24VE214/mWT/xDQYPvVYUSWfRQwnl
         fFIUceO+1YK3XJ2mLjULUlLksCg2bDUakUQlebnlDuQrL8KoWT/ebZaWCIN28a/ZX14f
         1k+xNyO59W4t8NvqK0KE5I1SiObcarSGLwfUlexah9T49wYpQMcpDFBnbY4Kvmw3FkUG
         rOYZg6DISvirJp/NrEBe7juXNrVkyxgfErqbej4PyY9Rhl/X1qK92yYxIAR+i25QecJ/
         n1MQ==
X-Google-Smtp-Source: AHgI3IakbtGYqM+ewKVAew/Zusknu3ALNnxN/Nf80/TGijJe/f7sNVo+lxNRjjn8bKcLJ2BEIUj2PsijmEUfhphmvns=
X-Received: by 2002:aca:3806:: with SMTP id f6mr10857802oia.47.1551106993935;
 Mon, 25 Feb 2019 07:03:13 -0800 (PST)
MIME-Version: 1.0
References: <20190211163653.97742-1-jannh@google.com> <f89de711-d73b-96be-75b6-0e9054022708@gmail.com>
In-Reply-To: <f89de711-d73b-96be-75b6-0e9054022708@gmail.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 25 Feb 2019 16:02:48 +0100
Message-ID: <CAG48ez2h6eavM9YWXYa69OLY7mFFKn1KN=roH2dZJCi7PSSmuQ@mail.gmail.com>
Subject: Re: [PATCH] mmap.2: describe the 5level paging hack
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: linux-man <linux-man@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Andy Lutomirski <luto@amacapital.net>, Dave Hansen <dave.hansen@intel.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, linux-arch <linux-arch@vger.kernel.org>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, 
	Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	linux-arm-kernel@lists.infradead.org, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 3:55 PM Michael Kerrisk (man-pages)
<mtk.manpages@gmail.com> wrote:
> On 2/11/19 5:36 PM, Jann Horn wrote:
> > The manpage is missing information about the compatibility hack for
> > 5-level paging that went in in 4.14, around commit ee00f4a32a76 ("x86/mm:
> > Allow userspace have mappings above 47-bit"). Add some information about
> > that.
> >
> > While I don't think any hardware supporting this is shipping yet (?), I
> > think it's useful to try to write a manpage for this API, partly to
> > figure out how usable that API actually is, and partly because when this
> > hardware does ship, it'd be nice if distro manpages had information about
> > how to use it.
> >
> > Signed-off-by: Jann Horn <jannh@google.com>
> > ---
> > This patch goes on top of the patch "[PATCH] mmap.2: fix description of
> > treatment of the hint" that I just sent, but I'm not sending them in a
> > series because I want the first one to go in, and I think this one might
> > be a bit more controversial.
> >
> > It would be nice if the architecture maintainers and mm folks could have
> > a look at this and check that what I wrote is right - I only looked at
> > the source for this, I haven't tried it.
> >
> >  man2/mmap.2 | 15 +++++++++++++++
> >  1 file changed, 15 insertions(+)
> >
> > diff --git a/man2/mmap.2 b/man2/mmap.2
> > index 8556bbfeb..977782fa8 100644
> > --- a/man2/mmap.2
> > +++ b/man2/mmap.2
> > @@ -67,6 +67,8 @@ is NULL,
> >  then the kernel chooses the (page-aligned) address
> >  at which to create the mapping;
> >  this is the most portable method of creating a new mapping.
> > +On Linux, in this case, the kernel may limit the maximum address that can be
> > +used for allocations to a legacy limit for compatibility reasons.
> >  If
> >  .I addr
> >  is not NULL,
> > @@ -77,6 +79,19 @@ or equal to the value specified by
> >  and attempt to create the mapping there.
> >  If another mapping already exists there, the kernel picks a new
> >  address, independent of the hint.
> > +However, if a hint above the architecture's legacy address limit is provided
> > +(on x86-64: above 0x7ffffffff000, on arm64: above 0x1000000000000, on ppc64 with
> > +book3s: above 0x7fffffffffff or 0x3fffffffffff, depending on page size), the
> > +kernel is permitted to allocate mappings beyond the architecture's legacy
> > +address limit. The availability of such addresses is hardware-dependent.
> > +Therefore, if you want to be able to use the full virtual address space of
> > +hardware that supports addresses beyond the legacy range, you need to specify an
> > +address above that limit; however, for security reasons, you should avoid
> > +specifying a fixed valid address outside the compatibility range,
> > +since that would reduce the value of userspace address space layout
> > +randomization. Therefore, it is recommended to specify an address
> > +.I beyond
> > +the end of the userspace address space.
> >  .\" Before Linux 2.6.24, the address was rounded up to the next page
> >  .\" boundary; since 2.6.24, it is rounded down!
> >  The address of the new mapping is returned as the result of the call.
> >
>
> Hi Jann,
>
> A few comments came in on this patch. Is there anything from
> those comments that should be rolled into the text?

Hi!

Yeah, I think all the feedback on the patch were good points, and I'll
have to integrate that into my patch.

