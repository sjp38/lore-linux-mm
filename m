Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4294C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69A4C208CB
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:17:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OC1UYhpB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69A4C208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F379B8E000C; Thu, 27 Jun 2019 09:17:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE7F68E0002; Thu, 27 Jun 2019 09:17:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD6DB8E000C; Thu, 27 Jun 2019 09:17:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB2588E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:17:13 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id i6so695033vsp.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:17:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=vy9qWbldNZVn/tHHwiK7Of/LXRmbGzfYDFquQFBj1LU=;
        b=K9g54XSSY2pFlR4+yzsO9HRlBBvXxHF9FIZpa3HR1496YWY/zAc9gTbJ6oXK4rPMgU
         j94283A3ufDlzEkZ+vbxKbek0KQbT7UBeTW0aagB7VenyrmVDBmeWs0MkIepUPJ6zDbk
         HgAJZqoT3t52b0E+S4frKhIEjTSvqZM2JHMbVutdDe9yBtsrGGGnhpXZc8I2cUTfGKDU
         OOqLH08uxBrPJRakWRROEpDGiOmL/DZyvBfzFrwU5QIwpd8IT/wDwCSbuwEbzu93Ynyl
         SM/aOqSDMZ+14+xIOI/Lwkl5Hc37WwBGQyQk3z4Ad3n3CAs36Uw11KYQGgmeoXLZgbkf
         ICew==
X-Gm-Message-State: APjAAAWEa8Aj5a0x/OpiRtTW7HKV4tkNbJ1R/+uSSdOJhvpHOwMEuygN
	635TDaCWKLTptKwhaG0W8qZdzS3sWSqIDZwFvrF2gv99hcCogcGVhVpy0WEqek5+a2v6XHbypK3
	KAB4THWP0Ow6AOG2ED+Y29Fh7oYt2WnXPuPg7TstJ3Y6JFeUInwg1jdDg8mPWHo4F3Q==
X-Received: by 2002:a1f:bf07:: with SMTP id p7mr1385040vkf.8.1561641433383;
        Thu, 27 Jun 2019 06:17:13 -0700 (PDT)
X-Received: by 2002:a1f:bf07:: with SMTP id p7mr1385011vkf.8.1561641432802;
        Thu, 27 Jun 2019 06:17:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561641432; cv=none;
        d=google.com; s=arc-20160816;
        b=M4+nqqLNaMKJZCwjG1YwH9HyPizgGgfE0qLIZ4kHSTYMPXaNWXPDQzN0qdZw0Mwcw/
         JBZ+x4BYEoiOkI/XFmXoNmlrLP2XlyYEE3+nYDeIdzVZcTheMRgFwetD1wroA5PjWln3
         5ajRLFqYaHMVfkjEUX/DbdFOw0MtAfsWs/Ao6xmLPGTMyy1mdu18lany+pl0IQZDGJIw
         qJtEKfevqn/AV06xUb2ATfCsvRYLOKTQf/kzM6u5tbmaWtErHfy0htYArYVCYQ+DdklR
         E4E48SgNOGcNXOCPoi7DAZG3oict1lGR1ZFrO23T1HEbdVjBlb/LqHVNqTcqnKUVnzDt
         nKog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=vy9qWbldNZVn/tHHwiK7Of/LXRmbGzfYDFquQFBj1LU=;
        b=toNetFmjbGn8dEvKlPfSrfc//sYGhbbQ2QXwurGQIZyN12K7yRVX9rjp/hqq/O+446
         LyC0MJzAFa5N4twDTV1ByMu1CQAZmktbIsj/fOXRsAFYJM1EFu8539w3KoZcNiscOxFL
         4VMW9Ce8JAJLW2ZHJUauNvcOPjnbf6JPHGiJ35qkXwbtOdvA2D+dAnVFthVQsEtHbN+H
         jLWgIXlZFpTB623n2iyJZr90puga7kPS+hx5FIGbTXfXbJWWiC9k6yVbBV5OIWc+Owr/
         9Mcs3ji57yZ0nGe5ubntGLh/jcQ6oZWoEwEmUOL0qr7AscvXCh8mIYba8MAkVfGAo3+b
         NdcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OC1UYhpB;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n10sor1062361uap.66.2019.06.27.06.17.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 06:17:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=OC1UYhpB;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=vy9qWbldNZVn/tHHwiK7Of/LXRmbGzfYDFquQFBj1LU=;
        b=OC1UYhpBFS959lMOYt/IcpryLBaWsNxeZVjDmulenf6LUHVyIdy908unuOq9TESJxu
         /jkJrUavVPEjsBXhsHduYzVOFoca0ZCd4/4qS+y7GeZOz2qnbNZ6yE2ezvymUQUwMXnR
         1VBmCcxbiwfi2K6u4ZxvPrSSuN3Y9Ij2zo7Bae2jaObMlfvrnv5Ov4dPgNdHTK+qdcws
         Xt7uk5cQg4hAD3lWE8r3HMBcfVDD3YNIQ0V1yLsVqZXyx0KXXdvzjV0oKSwobxrX9bD6
         jVZoIO6OtjAntp/8ckwjiNzV+G7Xru+qFaE5KcbKor98V1qhpmDHM3UagK4fo3NvTHvd
         Qs7g==
X-Google-Smtp-Source: APXvYqztRBRUmdw5LT1ObTf3jCkBOxfHFV2ozeQLBqAbyAIQTUUdoZukbB+6Skv3+6Fb/xNGQlqQRi+6N5axxh0px5w=
X-Received: by 2002:ab0:308c:: with SMTP id h12mr2232235ual.72.1561641432229;
 Thu, 27 Jun 2019 06:17:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190626121943.131390-1-glider@google.com> <20190626121943.131390-2-glider@google.com>
 <20190626162835.0947684d36ef01639f969232@linux-foundation.org>
In-Reply-To: <20190626162835.0947684d36ef01639f969232@linux-foundation.org>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 27 Jun 2019 15:17:00 +0200
Message-ID: <CAG_fn=WM_x9wUQNCwGB7BnKJqSpTMZGcf1Jxae-PHij8E9igjg@mail.gmail.com>
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Hocko <mhocko@kernel.org>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Qian Cai <cai@lca.pw>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 27, 2019 at 1:28 AM Andrew Morton <akpm@linux-foundation.org> w=
rote:
>
> On Wed, 26 Jun 2019 14:19:42 +0200 Alexander Potapenko <glider@google.com=
> wrote:
>
> >  v8:
> >   - addressed comments by Michal Hocko: revert kernel/kexec_core.c and
> >     apply initialization in dma_pool_free()
> >   - disable init_on_alloc/init_on_free if slab poisoning or page
> >     poisoning are enabled, as requested by Qian Cai
> >   - skip the redzone when initializing a freed heap object, as requeste=
d
> >     by Qian Cai and Kees Cook
> >   - use s->offset to address the freeptr (suggested by Kees Cook)
> >   - updated the patch description, added Signed-off-by: tag
>
> v8 failed to incorporate
>
> https://ozlabs.org/~akpm/mmots/broken-out/mm-security-introduce-init_on_a=
lloc=3D1-and-init_on_free=3D1-boot-options-fix.patch
> and
> https://ozlabs.org/~akpm/mmots/broken-out/mm-security-introduce-init_on_a=
lloc=3D1-and-init_on_free=3D1-boot-options-fix-2.patch
>
> it's conventional to incorporate such fixes when preparing a new
> version of a patch.
>
v9 contains these patches (I've also exported init_on_free), so should
now be fine to drop them.

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

