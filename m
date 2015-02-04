Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id C0F306B00A0
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 19:10:16 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so102682456pac.13
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 16:10:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ds17si114855pdb.31.2015.02.03.16.10.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Feb 2015 16:10:15 -0800 (PST)
Date: Tue, 3 Feb 2015 16:10:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 18/19] module: fix types of device tables aliases
Message-Id: <20150203161014.05c6f1dc47654b2e1fbc66a5@linux-foundation.org>
In-Reply-To: <54D16144.1010607@oracle.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
	<1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
	<20150203155145.632f352695fc558083d8c054@linux-foundation.org>
	<54D16144.1010607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, James Bottomley <James.Bottomley@HansenPartnership.com>

On Tue, 03 Feb 2015 19:01:08 -0500 Sasha Levin <sasha.levin@oracle.com> wrote:

> > diff -puN drivers/scsi/be2iscsi/be_main.c~module_device_table-fix-some-callsites drivers/scsi/be2iscsi/be_main.c
> > --- a/drivers/scsi/be2iscsi/be_main.c~module_device_table-fix-some-callsites
> > +++ a/drivers/scsi/be2iscsi/be_main.c
> > @@ -48,7 +48,6 @@ static unsigned int be_iopoll_budget = 1
> >  static unsigned int be_max_phys_size = 64;
> >  static unsigned int enable_msix = 1;
> >  
> > -MODULE_DEVICE_TABLE(pci, beiscsi_pci_id_table);
> >  MODULE_DESCRIPTION(DRV_DESC " " BUILD_STR);
> >  MODULE_VERSION(BUILD_STR);
> >  MODULE_AUTHOR("Emulex Corporation");
> 
> This just removes MODULE_DEVICE_TABLE() rather than moving it to after the
> definition of beiscsi_pci_id_table.

There's already a MODULE_DEVICE_TABLE() after the beiscsi_pci_id_table
definition. 

drivers/net/ethernet/emulex/benet/be_main.c did the same thing. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
