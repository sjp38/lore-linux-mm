Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A36146B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:08:44 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q23so8783546otg.9
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 08:08:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y14si703191oti.25.2018.10.12.08.08.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 08:08:42 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9CF7uI3140106
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:08:41 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n2v5f518g-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 11:08:40 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <schwidefsky@de.ibm.com>;
	Fri, 12 Oct 2018 16:08:38 +0100
Date: Fri, 12 Oct 2018 17:08:33 +0200
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: s390: runtime warning about pgtables_bytes
In-Reply-To: <20181011150211.7d8c07ac@mschwideX1>
References: <CAEemH2eExK_jwOPZDFBZkwABucpZqh+=s+qpN-tFfMzxwo7cZA@mail.gmail.com>
	<20181011150211.7d8c07ac@mschwideX1>
Message-Id: <20181012170833.2a05f308@mschwideX1>
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: Quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@redhat.com>
Cc: Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, 11 Oct 2018 15:02:11 +0200
Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:

> On Thu, 11 Oct 2018 18:04:12 +0800
> Li Wang <liwang@redhat.com> wrote:
>=20
> > When running s390 system with LTP/cve-2017-17052.c[1], the following BU=
G is
> > came out repeatedly.
> > I remember this warning start from kernel-4.16.0 and now it still exist=
 in
> > kernel-4.19-rc7.
> > Can anyone take a look?
> >=20
> > [ 2678.991496] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.001543] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.002453] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.003256] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.013689] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.024647] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.064408] BUG: non-zero pgtables_bytes on freeing mm: 16384
> > [ 2679.133963] BUG: non-zero pgtables_bytes on freeing mm: 16384
> >=20
> > [1]:
> > https://github.com/linux-test-project/ltp/blob/master/testcases/cve/cve=
-2017-17052.c=20=20
>=20=20
> Confirmed, I see this bug with cvs-2017-17052 on my LPAR as well.
> I'll look into it.
=20
Ok, I think I understand the problem now. This is the patch I am testing
right now. It seems to fix the issue, but I had to change common mm
code for it.
--
