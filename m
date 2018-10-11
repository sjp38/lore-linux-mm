Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7EABB6B0003
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:02:20 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b76-v6so4901649ywb.11
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 06:02:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v18-v6si7447474ybm.455.2018.10.11.06.02.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Oct 2018 06:02:19 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9BCrq5F069395
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:02:18 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2n268a2q21-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 09:02:18 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Thu, 11 Oct 2018 14:02:16 +0100
Date: Thu, 11 Oct 2018 15:02:11 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: s390: runtime warning about pgtables_bytes
In-Reply-To: <CAEemH2eExK_jwOPZDFBZkwABucpZqh+=s+qpN-tFfMzxwo7cZA@mail.gmail.com>
References: <CAEemH2eExK_jwOPZDFBZkwABucpZqh+=s+qpN-tFfMzxwo7cZA@mail.gmail.com>
Message-Id: <20181011150211.7d8c07ac@mschwideX1>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: Quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, 11 Oct 2018 18:04:12 +0800
Li Wang <liwang@redhat.com> wrote:

> When running s390 system with LTP/cve-2017-17052.c[1], the following BUG =
is
> came out repeatedly.
> I remember this warning start from kernel-4.16.0 and now it still exist in
> kernel-4.19-rc7.
> Can anyone take a look?
>=20
> [ 2678.991496] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.001543] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.002453] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.003256] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.013689] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.024647] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.064408] BUG: non-zero pgtables_bytes on freeing mm: 16384
> [ 2679.133963] BUG: non-zero pgtables_bytes on freeing mm: 16384
>=20
> [1]:
> https://github.com/linux-test-project/ltp/blob/master/testcases/cve/cve-2=
017-17052.c
=20
Confirmed, I see this bug with cvs-2017-17052 on my LPAR as well.
I'll look into it.

--=20
blue skies,
   Martin.

"Reality continues to ruin my life." - Calvin.
