Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 12E376B009D
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 19:01:49 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id kq14so102645722pab.0
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 16:01:48 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id pg5si709159pbb.153.2015.02.03.16.01.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 03 Feb 2015 16:01:48 -0800 (PST)
Message-ID: <54D16144.1010607@oracle.com>
Date: Tue, 03 Feb 2015 19:01:08 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v11 18/19] module: fix types of device tables aliases
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>	<1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>	<1422985392-28652-19-git-send-email-a.ryabinin@samsung.com> <20150203155145.632f352695fc558083d8c054@linux-foundation.org>
In-Reply-To: <20150203155145.632f352695fc558083d8c054@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Rusty Russell <rusty@rustcorp.com.au>, James Bottomley <James.Bottomley@HansenPartnership.com>

On 02/03/2015 06:51 PM, Andrew Morton wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: MODULE_DEVICE_TABLE: fix some callsites
> 
> The patch "module: fix types of device tables aliases" newly requires that
> invokations of
  invocations
> 
> MODULE_DEVICE_TABLE(type, name);
> 
> come *after* the definition of `name'.  That is reasonable, but some
> drivers weren't doing this.  Fix them.
> 
> Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
> Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/scsi/be2iscsi/be_main.c |    1 -
>  1 file changed, 1 deletion(-)
> 
> diff -puN drivers/scsi/be2iscsi/be_main.c~module_device_table-fix-some-callsites drivers/scsi/be2iscsi/be_main.c
> --- a/drivers/scsi/be2iscsi/be_main.c~module_device_table-fix-some-callsites
> +++ a/drivers/scsi/be2iscsi/be_main.c
> @@ -48,7 +48,6 @@ static unsigned int be_iopoll_budget = 1
>  static unsigned int be_max_phys_size = 64;
>  static unsigned int enable_msix = 1;
>  
> -MODULE_DEVICE_TABLE(pci, beiscsi_pci_id_table);
>  MODULE_DESCRIPTION(DRV_DESC " " BUILD_STR);
>  MODULE_VERSION(BUILD_STR);
>  MODULE_AUTHOR("Emulex Corporation");

This just removes MODULE_DEVICE_TABLE() rather than moving it to after the
definition of beiscsi_pci_id_table.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
