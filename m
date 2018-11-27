Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 05A1F6B47B8
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:52:30 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id l45so10729670edb.1
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 03:52:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h2-v6si1745158ejq.203.2018.11.27.03.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 03:52:28 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wARBi2OF075255
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:52:27 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p148mbd9f-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 06:52:27 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 27 Nov 2018 11:52:25 -0000
Date: Tue, 27 Nov 2018 12:52:11 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
 <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
 <20181031100944.GA3546@osiris>
 <20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
 <20181127073411.GA3625@osiris>
 <fa0269be-48e5-c987-50b6-4dc94ac8f086@roeck-us.net>
In-Reply-To: <fa0269be-48e5-c987-50b6-4dc94ac8f086@roeck-us.net>
Message-Id: <20181127115211.GD3625@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: Quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Li Wang <liwang@redhat.com>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Tue, Nov 27, 2018 at 03:47:13AM -0800, Guenter Roeck wrote:
> >E.g. something like the below. If there aren't any objections, I will
> >provide a proper patch with changelog, etc.
> >
> >diff --git a/kernel/fork.c b/kernel/fork.c
> >index 07cddff89c7b..d7aeec03c57f 100644
> >--- a/kernel/fork.c
> >+++ b/kernel/fork.c
> >@@ -647,8 +647,8 @@ static void check_mm(struct mm_struct *mm)
> >  	}
> >  	if (mm_pgtables_bytes(mm))
> >-		pr_alert("BUG: non-zero pgtables_bytes on freeing mm: %ld\n",
> >-				mm_pgtables_bytes(mm));
> >+		printk_once(KERN_ALERT "BUG: non-zero pgtables_bytes on freeing mm: %=
ld\n",
> >+			    mm_pgtables_bytes(mm));
>=20
> pr_alert_once ?

Already changed and posted:

https://lore.kernel.org/lkml/20181127083603.39041-1-heiko.carstens@de.ibm.c=
om/
