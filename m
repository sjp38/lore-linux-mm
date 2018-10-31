Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5056B0282
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:09:53 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id w131-v6so234329oie.4
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 03:09:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id v14si11803401otj.229.2018.10.31.03.09.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 03:09:52 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9VA4R8K016473
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:09:52 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2nf9rhsqg8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:09:51 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 31 Oct 2018 10:09:50 -0000
Date: Wed, 31 Oct 2018 11:09:44 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
 <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
MIME-Version: 1.0
In-Reply-To: <20181031073149.55ddc085@mschwideX1>
Message-Id: <20181031100944.GA3546@osiris>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Oct 31, 2018 at 07:31:49AM +0100, Martin Schwidefsky wrote:
> Thanks for testing. Unfortunately Heiko reported another issue yesterday
> with the patch applied. This time the other way around:
> 
> BUG: non-zero pgtables_bytes on freeing mm: -16384
> 
> I am trying to understand how this can happen. For now I would like to
> keep the patch on hold in case they need another change.

FWIW, Kirill: is there a reason why this "BUG:" output is done with
pr_alert() and not with VM_BUG_ON() or one of the WARN*() variants?

That would to get more information with DEBUG_VM and / or
panic_on_warn=1 set. At least for automated testing it would be nice
to have such triggers.
