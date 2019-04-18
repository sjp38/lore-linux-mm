Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3C8FC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A206421479
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 16:43:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="PSoUbECw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A206421479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44E996B0005; Thu, 18 Apr 2019 12:43:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FCA26B0006; Thu, 18 Apr 2019 12:43:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 314226B0007; Thu, 18 Apr 2019 12:43:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0B2B46B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 12:43:40 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id t85so699716vsc.21
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:43:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=qzDLwBi5wGEl1QgiX6QazcN46g8jvDRco924zpUMTMs=;
        b=UFLtE7vPTrLfW4rItwCPJph9lmE/SeecFdSL2uRondYeebXIHKjWNWTL6cE339p39F
         FbktyToa2AIPPuuAmVAZ4+VnjAkFgOsuEDJZcqHZAOCXYADl9E0XNOOGhAZketIUhTVp
         lyjDBbJe/86PHiVRkeQpozJC0LZOd4iGf14ykY1c33pWrcJoKoWz4FzJvTGtbQO9d/H4
         PTJc3xLr23DZYcczQMmEMXPcGs1wNWclJhimlX09/Q3/VJRjFaN8i4hjI8VkXaWYbkrB
         t41cgAr27GMK3QKA0xSU1XUEFVbSHJp1koCmfaIqs3NQ+BrCdXLRsO7IAdmKsq54N6Fc
         i45Q==
X-Gm-Message-State: APjAAAULPatXf5xayclJTUqGJbFBplZyG2xvnF1152hZumreLeQVp5o4
	K7htKg8GPR+P/2FA1sSuTHcBij+189qrCWlNuC1imUWMMtd3iOepQZCfl2DUC7O8oRweG0y0R5y
	qMF1hCK2P6foNp6PhUK5d54enq87DDQCP4ogXWLFQSUcFlgLTxDlXtlsYefc4rUeJiw==
X-Received: by 2002:a1f:1d06:: with SMTP id d6mr50596842vkd.82.1555605819608;
        Thu, 18 Apr 2019 09:43:39 -0700 (PDT)
X-Received: by 2002:a1f:1d06:: with SMTP id d6mr50596773vkd.82.1555605818915;
        Thu, 18 Apr 2019 09:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555605818; cv=none;
        d=google.com; s=arc-20160816;
        b=DsXytAVbVZPxBbdaWTWS/M64lqQ4qQkyvSGpiBDNMbnT+jC/vxfkUOrpfVf99+oW6t
         nG44hIv4O0wEhUYAVHNuTdvQ1CL4CvMbRoohDhh5urQ69l1F7YjMX3F5PNXLqLc+XRJq
         DLs8sIHR87cugkD5UVINDtSjzaikAgqpmnr0HrTNURyUASs221/yqBLiDAN1T11QDSkE
         vkv3oa2HK3fxkebB+fiR3L1Pn1N5lSexOcIY3SYZRlUh665ANeeupxX4QUAnlIOANNcp
         XSRtIjhWmrvbGM8VpRCluWORQtAbk/UinAO6+lh/2R1dQYycG3DWnOKnf3wL7fCddaD8
         oJPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=qzDLwBi5wGEl1QgiX6QazcN46g8jvDRco924zpUMTMs=;
        b=fbwYRHTb33zF5shIqJVsCEz9462tUuH9W5BVnINZk120k9/5kga1Qz9F6egneYdY0R
         saZAGvIQUAf9t/F025pi1m6K4LyJE3997O9shK555xBTn/X2dQi5G7nP7cqPiEAhhONP
         791jUEZi9W3DGpHLCt+vde8JaPYprLw0zLT+eUlnkRqbndriByvfJ5a13quMgIl8KNEA
         SWwansYSbWD/WrQX6O6fgwt0MozxmmW+4bQTd/4gNypMp9zy4MonDy5fm26QRx4rjTxS
         OsU/xo1LM08DAPyd2nfyIXKTS+7F0k33EA02Kbyeh7dapcboJreNQFviDQEBpZelX6QG
         k81A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PSoUbECw;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor895508vkp.61.2019.04.18.09.43.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Apr 2019 09:43:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=PSoUbECw;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=qzDLwBi5wGEl1QgiX6QazcN46g8jvDRco924zpUMTMs=;
        b=PSoUbECw7vwP45yX9rJ82zoosI6vrtSOcSvfexvtf9HX8wWoR5wUcRHsD9B7m5U2L7
         jm9HH/bjxBGxi5+RCrCNLXetskJuMX2wfqmhBCXUlHJ5ijkxaWsjVIfbRyqsmp7XKLdh
         gYaCyM7a99gS3drFWq3+iozBqgt+Qo29xLYJQvM/9GciLdkCCn30jwwNsdm+C4McJcqX
         Ch2reOgZolGTpLBTrvtU/hr3aOBRzPcAWcPskgQk1pCvXRAGZ/MNcAluPTK+LTpj6hfe
         oANJOvhbEp4yaN6R0AknZ+86wyCf7mZASFmzpqE0QfOYMcxeh4Oe96IoxGwr6LTvlJTJ
         qp2w==
X-Google-Smtp-Source: APXvYqyn9J+QqZgKJjQGoBk6T1xIB+6KLK6AJT56KZhqtsU+SxO6Kwx1Y5gtrSBkkcrVh5eG2zk2CkqmsC41n5XBaIc=
X-Received: by 2002:a1f:aa93:: with SMTP id t141mr50445492vke.64.1555605818227;
 Thu, 18 Apr 2019 09:43:38 -0700 (PDT)
MIME-Version: 1.0
References: <20190418154208.131118-1-glider@google.com> <20190418154208.131118-2-glider@google.com>
 <981d439a-1107-2730-f27e-17635ee4a125@intel.com>
In-Reply-To: <981d439a-1107-2730-f27e-17635ee4a125@intel.com>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 18 Apr 2019 18:43:27 +0200
Message-ID: <CAG_fn=URD0WL+RE90ZE2FZM4=p2zE9V+YA2RW-LrWnuqYTwvKQ@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: security: introduce the init_allocations=1 boot option
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Dmitriy Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, 
	Laura Abbott <labbott@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 6:35 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 4/18/19 8:42 AM, Alexander Potapenko wrote:
> > This option adds the possibility to initialize newly allocated pages an=
d
> > heap objects with zeroes. This is needed to prevent possible informatio=
n
> > leaks and make the control-flow bugs that depend on uninitialized value=
s
> > more deterministic.
>
> Isn't it better to do this at free time rather than allocation time?  If
> doing it at free, you can't even have information leaks for pages that
> are in the allocator.
I should have mentioned this in the patch description, as this
question is being asked every time I send a patch :)
If we want to avoid double initialization and take advantage of
__GFP_NOINIT (see the second and third patches in the series) we need
to do initialize the memory at allocation time, because free() and
free_pages() don't accept GFP flags.



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

