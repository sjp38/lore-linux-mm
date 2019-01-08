Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1EC2C43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 21:14:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A054F20883
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 21:14:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="n7ju5MIS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A054F20883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D05A8E009D; Tue,  8 Jan 2019 16:14:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17DB48E0038; Tue,  8 Jan 2019 16:14:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06E0B8E009D; Tue,  8 Jan 2019 16:14:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id CC2698E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 16:14:40 -0500 (EST)
Received: by mail-vk1-f200.google.com with SMTP id o11so1145221vke.5
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:14:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=OWEgAtYm9ccvWmLV8AYycOen3jNVVZL7snbVRoC2Jsg=;
        b=qfr16+XAzERA7/ht3D7Tpd/F2UIPZhVJISycuMwpaKdkfAddtJDF5xfA72LxR+DBHI
         TVrO8r+Tj63/ZJs9wXXSGddSvzvsTbcwPaDh55Jx3NwJLbFWgHZBhMEKeSB7rQ85jApe
         fsqKTmfKPCIQtgE5EjpeKX9OikO+HMBO2d5rfPgFOMMwXuSA80GsKXSXfRDtPCVtxqWx
         phTp7g1pcxOYjsUmFezMHkMYyjzIn55nxDXE30uSFghOtDMEF8NoDa9aIR69+znnUPK+
         adiDKRsvvqkhqk+cU5nPNoMNdPkMeQEio81kJscra/pfTVJo1hV7N9KRQYjhsX/96cvE
         /ZyQ==
X-Gm-Message-State: AJcUukeqXvPlC1vHOdMB3BS29LFJUcRzXQo2C+Sg0J+W5rO9kTu+5oNZ
	/aQeRqK72bGncg+lS4AhaWgZNbHYRx03XBb7r7mcgdhh0wzVGGLqdqjou7k3OqrvUixiB/8cY0A
	ViQgqIMXKAuCtU9CBc0cURe859B/sB9Rc0aJUzdFe065hoTSOjLxezsMUOAz/LR4d1G9GQHuHwX
	owbTm5Mx8ZjVdS8oyZHe6OvwUY/16t8oxBWzoEauPo/UM5xQqTQULziQ49r99FGeLELiHHPNPon
	MZ/vaTna9g/mGwLaHkepUIgxGjQVdJRzJRIQJVDprEqntopbWo8FSfrRUA2qT1P1+95FnM00g4b
	BIKQrQrFYyWef5u/LePPjYyLkPb91+i1CFI77jmDuBi1k1gD4TfREEIfgaecHBG49blKLSMrgCp
	c
X-Received: by 2002:a1f:7d02:: with SMTP id y2mr1218308vkc.62.1546982080376;
        Tue, 08 Jan 2019 13:14:40 -0800 (PST)
X-Received: by 2002:a1f:7d02:: with SMTP id y2mr1218293vkc.62.1546982079628;
        Tue, 08 Jan 2019 13:14:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546982079; cv=none;
        d=google.com; s=arc-20160816;
        b=Ppj2A1HZrZXVwXSUnt3OlrpxOnAE5EoJcP4DXRQSPodfSS6OQWox2yX++guVxjJPvi
         NGg5yXu8AHg7oa7ufPwxrN7ZRAl1WWfNHC06pxhATfR0leiLhHDc29rvMGqQh0BaXCui
         OO7s5fbomkI9FLIoJgg88ZqI0yYHsdeYF8K8F9OmRxUnmNf1Lf7b885C3it3DGiOiJjq
         jE7TYlD+JnQPndZLwWXW4cb1nTeyXF6oPRVohYVcowYYhxMKLAM+JrVHP4YhQSk7zJjG
         cbZhZ0KsecDUCrWpO/qZfRedW3z5N1AJQGwgVgrjQE+tZRvaGC/rlmDIoC65j8mhsPQ9
         txlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=OWEgAtYm9ccvWmLV8AYycOen3jNVVZL7snbVRoC2Jsg=;
        b=H0fFMxUSePJWB6MDIktJnTZ7QySsoO0HSmW3PEHEMlpQplEI7+wispMUqJ47StvCa0
         Xvz4kmMne4cLXu26YTgH4sBcIzrbs0pblQnzf3g/ntrZH5Of3qz2UJOUGRI+nbd6OWtf
         OPm7mN78ihnYUzNC0JpweLfpr7hmMPNOzyjkNAovHLuWkllmobWOem+GcmOcItC5IK0S
         AkpYXMug11usSzkGAkzLJKuufw2HWnVWLt52Ev3WFPSPZ6vlmwopIAdLkFmKBqPSKYj4
         tCnuIue2TkHGbL0E42mkmBcaNb/hDt5wi/ByOwIMpkfpuwOdRBNekfLbWSXcjzcsokko
         X6gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=n7ju5MIS;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x23sor40887910ual.39.2019.01.08.13.14.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 13:14:39 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=n7ju5MIS;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=OWEgAtYm9ccvWmLV8AYycOen3jNVVZL7snbVRoC2Jsg=;
        b=n7ju5MISRSee7cLJdLngz1Mdb6LlSBCNk8BK8mRbvDLCmqIsKwDKgdHG/wpLbfSBDJ
         SslGEZS8PDhaSwt3lQpLhP4l0PkbnC4k65ZU+BViOEDXcmtKOLwmBcFkBtFv2VfDWijN
         PUwrTtMH0L7MMnQ5Ibrdde0Pe3QpqRMBUt234=
X-Google-Smtp-Source: ALg8bN6OmpumwPoKNV9O3AvKNCqedldSt2dssq5MB1HcAhLIJsusD4Eq4NllhTGpNpom1Oy3Se9VWA==
X-Received: by 2002:ab0:744f:: with SMTP id p15mr1240870uaq.19.1546982078885;
        Tue, 08 Jan 2019 13:14:38 -0800 (PST)
Received: from mail-vk1-f176.google.com (mail-vk1-f176.google.com. [209.85.221.176])
        by smtp.gmail.com with ESMTPSA id j95sm34846151uad.6.2019.01.08.13.14.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 13:14:37 -0800 (PST)
Received: by mail-vk1-f176.google.com with SMTP id y14so1212953vkd.1
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:14:37 -0800 (PST)
X-Received: by 2002:a1f:4982:: with SMTP id w124mr1240075vka.4.1546982076925;
 Tue, 08 Jan 2019 13:14:36 -0800 (PST)
MIME-Version: 1.0
References: <0b0db24e18063076e9d9f4e376994af83da05456.1546932949.git.christophe.leroy@c-s.fr>
 <20190108114803.583f203b86d4a368ac9796f3@linux-foundation.org> <19c99d33-b796-72df-4212-20255f84efa0@c-s.fr>
In-Reply-To: <19c99d33-b796-72df-4212-20255f84efa0@c-s.fr>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 8 Jan 2019 13:14:25 -0800
X-Gmail-Original-Message-ID: <CAGXu5j+8XqMu596gtzRAjV=7cv2rThcE5-Wy6QTmNzdht3k66w@mail.gmail.com>
Message-ID:
 <CAGXu5j+8XqMu596gtzRAjV=7cv2rThcE5-Wy6QTmNzdht3k66w@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: add probe_user_read()
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Mike Rapoport <rppt@linux.ibm.com>, 
	LKML <linux-kernel@vger.kernel.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, 
	Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108211425.ppr2EI5fLlpOkM_QLAaEZi6neZu1Wskd8bfK0m-rprc@z>

On Tue, Jan 8, 2019 at 1:11 PM Christophe Leroy <christophe.leroy@c-s.fr> w=
rote:
>
>
>
> Le 08/01/2019 =C3=A0 20:48, Andrew Morton a =C3=A9crit :
> > On Tue,  8 Jan 2019 07:37:44 +0000 (UTC) Christophe Leroy <christophe.l=
eroy@c-s.fr> wrote:
> >
> >> In powerpc code, there are several places implementing safe
> >> access to user data. This is sometimes implemented using
> >> probe_kernel_address() with additional access_ok() verification,
> >> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> >> pair, etc. :
> >>      show_user_instructions()
> >>      bad_stack_expansion()
> >>      p9_hmi_special_emu()
> >>      fsl_pci_mcheck_exception()
> >>      read_user_stack_64()
> >>      read_user_stack_32() on PPC64
> >>      read_user_stack_32() on PPC32
> >>      power_pmu_bhrb_to()
> >>
> >> In the same spirit as probe_kernel_read(), this patch adds
> >> probe_user_read().
> >>
> >> probe_user_read() does the same as probe_kernel_read() but
> >> first checks that it is really a user address.
> >>
> >> ...
> >>
> >> --- a/include/linux/uaccess.h
> >> +++ b/include/linux/uaccess.h
> >> @@ -263,6 +263,40 @@ extern long strncpy_from_unsafe(char *dst, const =
void *unsafe_addr, long count);
> >>   #define probe_kernel_address(addr, retval)         \
> >>      probe_kernel_read(&retval, addr, sizeof(retval))
> >>
> >> +/**
> >> + * probe_user_read(): safely attempt to read from a user location
> >> + * @dst: pointer to the buffer that shall take the data
> >> + * @src: address to read from
> >> + * @size: size of the data chunk
> >> + *
> >> + * Returns: 0 on success, -EFAULT on error.
> >> + *
> >> + * Safely read from address @src to the buffer at @dst.  If a kernel =
fault
> >> + * happens, handle that and return -EFAULT.
> >> + *
> >> + * We ensure that the copy_from_user is executed in atomic context so=
 that
> >> + * do_page_fault() doesn't attempt to take mmap_sem.  This makes
> >> + * probe_user_read() suitable for use within regions where the caller
> >> + * already holds mmap_sem, or other locks which nest inside mmap_sem.
> >> + */
> >> +
> >> +#ifndef probe_user_read
> >> +static __always_inline long probe_user_read(void *dst, const void __u=
ser *src,
> >> +                                        size_t size)
> >> +{
> >> +    long ret;
> >> +
> >> +    if (!access_ok(src, size))
> >> +            return -EFAULT;
> >> +
> >> +    pagefault_disable();
> >> +    ret =3D __copy_from_user_inatomic(dst, src, size);
> >> +    pagefault_enable();
> >> +
> >> +    return ret ? -EFAULT : 0;
> >> +}
> >> +#endif
> >
> > Why was the __always_inline needed?
> >
> > This function is pretty large.  Why is it inlined?
> >
>
> Kees told to do that way, see https://patchwork.ozlabs.org/patch/986848/

Yeah, I'd like to make sure we can plumb the size checks down into the
user copy primitives.

--=20
Kees Cook

