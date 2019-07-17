Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 837E7C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E6562184E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 22:00:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E6562184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=altlinux.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8815A6B000A; Wed, 17 Jul 2019 17:59:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BD666B000C; Wed, 17 Jul 2019 17:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 636EA8E0001; Wed, 17 Jul 2019 17:59:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF7346B000A
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:59:58 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e20so5609031ljk.2
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:59:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=8umHCL11V8/kpav32cTX1SEwS3ndsiFvlSKqKerdqDY=;
        b=nsHbkg4Ttxvw0SYA/jLOhatymJ6h9pfoZOP0zsc8lfnGaKZFAKEUSIuRw158p6X0qc
         E0ngjo8RoMdroiMIneoCur+PEie3YlD73cw6CjvK4A4cg2fQzI4T+BIMF5n2wKmNwUp2
         5dyXg4jAv+Kwn9JkIqddogmQVaYuVbS9qdl8UTQAShs3dcEoaDVk3tVNPAkqNFJd12bR
         yAjctA1IZqDqDPlT7yyPoh3cONJCo0hI8FCeVTMNGuPUkZnfGA8SpwpHPCFUpOrdzxRD
         Ku7ZtxF+tkzXhCrBN6XBaL7C8CPTIANLJO5iQ6snyX3YBZUYtjW9Tucdga/+NWLX3zez
         ggmQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) smtp.mailfrom=ldv@altlinux.org
X-Gm-Message-State: APjAAAVkeMcxR8wyCQYL5yJRWZfP9U6IyRFmFH1wj7bq97SIt3EroGHX
	DeKaKGsnCUOut+mH/9KdFwk+LzWezrBaLVLJX7LgLTA7m375qFJT0KAxy+bv1jmG8Ee8uG9zzx3
	pzhfqFqKypwva/dIMLWIGtg0SdqEmWswU+Nve0TV9fAmyf879ivR8lm2jRygrwhvrHg==
X-Received: by 2002:ac2:5609:: with SMTP id v9mr18229854lfd.27.1563400798386;
        Wed, 17 Jul 2019 14:59:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMzaOQUaTolJ65TAp36S3Ca8Lxt07vv/vhoPgxAjjb8j1chTvNJc3xoAfHskwbxXCq/xub
X-Received: by 2002:ac2:5609:: with SMTP id v9mr18229828lfd.27.1563400797391;
        Wed, 17 Jul 2019 14:59:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563400797; cv=none;
        d=google.com; s=arc-20160816;
        b=YZ17qHULRPL0ISj/0ZlTZFk0dola70Iw5rOEu+txoSaz4CqiA9g7dFKRR6qZpWWMQN
         oK9aLIdrHAg7Nu3nWwQE3+4QsELGLLRrSZJo7jSdqvXRVxaywpaVfXP2FHdyNLp5qXUC
         zkYaktlavwZVScn4v3rxpJ5Dr43MTbdwVo6Fda0eTYOqQWgD6A8wCZQ6x6i6ZSI5yyVf
         U3njtYtolex6u2/OsdGgijKorlq4N3uXzyznz8eHVQ7b1AIO8ls7S+AGwZVemCVZkEf4
         2dZXmeR8SnWpPXh1GXytx5J+l1Y183TuPKXFjOq8fHn1FkB+A9tuFrlTSzMF4YaZV03p
         nA3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=8umHCL11V8/kpav32cTX1SEwS3ndsiFvlSKqKerdqDY=;
        b=rIWqfse4ZUWMNy+ikEdchJsakWWR2Vpx3ii6SdL1qpNAIgwrPR0KA+TQ7QhWVeGhQa
         thWQzIPfSBtGO4nAbLjQ9lcSTULtBLhsPVkAiIui/57DZtvEyZ0IKGa1473SJSYy4PhS
         W42qC1oER+0lW+AI5G5C/UphuoFDC/yEOSsxRDSKbYEH2x7FJaCgGrDgeMLdPZfFY9rQ
         oaXZJNhkcFzvBd7pIPq39ntjDO0kSbSgsOgDIVtH5kBlhZaUp15+Rd8WAtKnhBqNfkLn
         TesOmyDm4TP8SvqTtBE5BS2P8DMW8MsZw67pPOII8dls2GlL450dnKJJU7bZWdqRKqRK
         VQWg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) smtp.mailfrom=ldv@altlinux.org
Received: from vmicros1.altlinux.org (vmicros1.altlinux.org. [194.107.17.57])
        by mx.google.com with ESMTP id 125si20220340lfl.11.2019.07.17.14.59.57
        for <linux-mm@kvack.org>;
        Wed, 17 Jul 2019 14:59:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) client-ip=194.107.17.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldv@altlinux.org designates 194.107.17.57 as permitted sender) smtp.mailfrom=ldv@altlinux.org
Received: from mua.local.altlinux.org (mua.local.altlinux.org [192.168.1.14])
	by vmicros1.altlinux.org (Postfix) with ESMTP id E34AB72CC64;
	Thu, 18 Jul 2019 00:59:56 +0300 (MSK)
Received: by mua.local.altlinux.org (Postfix, from userid 508)
	id C53317CCE5C; Thu, 18 Jul 2019 00:59:56 +0300 (MSK)
Date: Thu, 18 Jul 2019 00:59:56 +0300
From: "Dmitry V. Levin" <ldv@altlinux.org>
To: Christoph Hellwig <hch@lst.de>, Khalid Aziz <khalid.aziz@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Anatoly Pugachev <matorola@gmail.com>, sparclinux@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
Message-ID: <20190717215956.GA30369@altlinux.org>
References: <20190625143715.1689-1-hch@lst.de>
 <20190625143715.1689-10-hch@lst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <20190625143715.1689-10-hch@lst.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jun 25, 2019 at 04:37:08PM +0200, Christoph Hellwig wrote:
> The sparc64 code is mostly equivalent to the generic one, minus various
> bugfixes and two arch overrides that this patch adds to pgtable.h.
>=20
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
> ---
>  arch/sparc/Kconfig                  |   1 +
>  arch/sparc/include/asm/pgtable_64.h |  18 ++
>  arch/sparc/mm/Makefile              |   2 +-
>  arch/sparc/mm/gup.c                 | 340 ----------------------------
>  4 files changed, 20 insertions(+), 341 deletions(-)
>  delete mode 100644 arch/sparc/mm/gup.c

So this ended up as commit 7b9afb86b6328f10dc2cad9223d7def12d60e505
(thanks to Anatoly for bisecting) and introduced a regression:=20
futex.test from the strace test suite now causes an Oops on sparc64
in futex syscall.

Here is a heavily stripped down reproducer:

// SPDX-License-Identifier: GPL-2.0-or-later
#include <err.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>
#include <asm/unistd.h>
int main(void)
{
	size_t page_size =3D sysconf(_SC_PAGESIZE);
	size_t alloc_size =3D 3 * page_size;
	void *p =3D mmap(NULL, alloc_size, PROT_READ | PROT_WRITE,
		       MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (MAP_FAILED =3D=3D p)
		err(EXIT_FAILURE, "mmap(%zu)", alloc_size);
	void *hole =3D p + page_size;
	if (munmap(hole, page_size))
		err(EXIT_FAILURE, "munmap(%p, %zu)", hole, page_size);
	syscall(__NR_futex, (unsigned long) hole, 0L, 0L, 0L, 0L, 0L);
	return 0;
}

--=20
ldv

--opJtzjQTFsWo+cga
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJdL5pcAAoJEAVFT+BVnCUIQ+4QAJbAg/fjGdrZiUuhFCsAumUr
1a+Sj62OxFSUDyqbMKHGYQndj9PAPc6CqjbaT02kKPqqCVKQsww+kLGHLOIBMq3G
4tK92yghsLeH7PiOgLNjBuLtZm3qySmxG1e5Wvt7/1AZeEZLvQit4Js1t0yUYgz2
copTaWXHLHUHQ9ePrzd4CyVo2Ha8ChhVATHAI9NSby1kqvBDG5Yt5pS6A14ocRH8
drd71GTLFu0pXWBh3dRSZ1irXnyL/SKYYGD6/kem1l8Bq8hVwfiLfwhhAl02Gmap
7wj/kYIG/aDFlK43ulBeXVwG/xFDdTVL5cOc8aS9x+160+jfzGRcSHdfUwnV3evI
0Qi66H4im83apvoaVOznNIk88x3omiN2XoYcWZjVazN6whSdmA4Oz3RMQxm9Epx3
heEwsaAX/5dGPwWG6JdZIktHIw+Z64egFm+5AXPRkGo2LUP6dgVew2dECP2+dl8H
E6o86lU2ctAaaeDCymH0w5cOVp9WPeEEEGxwuIai7LZN3GuFP+/hwEsPMrRtIhsD
NVmq/JPWACqixvfHL7t1UpZkwvJxraR/V4v4cjC7jW1kE73AlF3xNxjJtOPQlesR
xQBuQ5ezVXipMyeC1a29NgKGCvMtxUvkszGmejsYUiplI2bI8g7uwhySqssqW+e9
7SxH0zcMsECH0iugLK5w
=+CIC
-----END PGP SIGNATURE-----

--opJtzjQTFsWo+cga--

