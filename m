Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0625C6B0293
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:36:31 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id w190-v6so11075953ywf.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 03:36:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w127-v6sor3241133ywf.54.2018.10.31.03.36.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Oct 2018 03:36:29 -0700 (PDT)
Date: Wed, 31 Oct 2018 13:36:23 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] s390/mm: fix mis-accounting of pgtable_bytes
Message-ID: <20181031103623.6ykzsjdenrpeth7x@kshutemo-mobl1>
References: <1539621759-5967-1-git-send-email-schwidefsky@de.ibm.com>
 <1539621759-5967-4-git-send-email-schwidefsky@de.ibm.com>
 <CAEemH2cHNFsiDqPF32K6TNn-XoXCRT0wP4ccAeah4bKHt=FKFA@mail.gmail.com>
 <20181031073149.55ddc085@mschwideX1>
 <20181031100944.GA3546@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181031100944.GA3546@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Li Wang <liwang@redhat.com>, Guenter Roeck <linux@roeck-us.net>, Janosch Frank <frankja@linux.vnet.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Wed, Oct 31, 2018 at 11:09:44AM +0100, Heiko Carstens wrote:
> On Wed, Oct 31, 2018 at 07:31:49AM +0100, Martin Schwidefsky wrote:
> > Thanks for testing. Unfortunately Heiko reported another issue yesterday
> > with the patch applied. This time the other way around:
> > 
> > BUG: non-zero pgtables_bytes on freeing mm: -16384
> > 
> > I am trying to understand how this can happen. For now I would like to
> > keep the patch on hold in case they need another change.
> 
> FWIW, Kirill: is there a reason why this "BUG:" output is done with
> pr_alert() and not with VM_BUG_ON() or one of the WARN*() variants?
> 
> That would to get more information with DEBUG_VM and / or
> panic_on_warn=1 set. At least for automated testing it would be nice
> to have such triggers.

Stack trace is not helpful there. It will always show the exit path which
is useless.

-- 
 Kirill A. Shutemov
