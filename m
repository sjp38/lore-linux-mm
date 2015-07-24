Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com [209.85.220.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3B739003C7
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 06:15:14 -0400 (EDT)
Received: by qkbm65 with SMTP id m65so11199152qkb.2
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 03:15:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g193si9411698qhc.81.2015.07.24.03.15.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jul 2015 03:15:14 -0700 (PDT)
Date: Fri, 24 Jul 2015 18:14:57 +0800
From: "dyoung@redhat.com" <dyoung@redhat.com>
Subject: Re: [PATCH mmotm] kexec: arch_kexec_apply_relocations can be static
Message-ID: <20150724101457.GA8405@localhost.localdomain>
References: <201507241644.XJlodOnm%fengguang.wu@intel.com>
 <20150724081102.GA239929@lkp-ib04>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150724081102.GA239929@lkp-ib04>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi, Fengguang

Justs be curious, is this been found by robot script?

On 07/24/15 at 04:11pm, kbuild test robot wrote:
> 
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  kexec_file.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
> index caf47e9..91e9e9d 100644
> --- a/kernel/kexec_file.c
> +++ b/kernel/kexec_file.c
> @@ -122,7 +122,7 @@ arch_kexec_apply_relocations_add(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
>  }
>  
>  /* Apply relocations of type REL */
> -int __weak
> +static int __weak
>  arch_kexec_apply_relocations(const Elf_Ehdr *ehdr, Elf_Shdr *sechdrs,
>  			     unsigned int relsec)
>  {

It is a weak function, why move it to static? There's also several other similar
functions in the file.

Thanks
Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
