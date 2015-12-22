Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id 961866B0022
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 06:49:56 -0500 (EST)
Received: by mail-yk0-f170.google.com with SMTP id x184so162208375yka.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 03:49:56 -0800 (PST)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id l127si24424521ywf.123.2015.12.22.03.49.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 Dec 2015 03:49:55 -0800 (PST)
Date: Tue, 22 Dec 2015 11:49:46 +0000
From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: arch/x86/xen/suspend.c:70:9: error: implicit declaration of
 function 'xen_pv_domain'
In-Reply-To: <20151221140704.e376871cd786498eb5e71352@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1512221142200.3096@kaball.uk.xensource.com>
References: <201512210015.cGubDgTR%fengguang.wu@intel.com>
 <20151221140704.e376871cd786498eb5e71352@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Sasha Levin <sasha.levin@oracle.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, David Vrabel <david.vrabel@citrix.com>, boris.ostrovsky@oracle.com

On Mon, 21 Dec 2015, Andrew Morton wrote:
> On Mon, 21 Dec 2015 00:43:17 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> 
> > First bad commit (maybe != root cause):
> > 
> > tree:   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   69c37a92ddbf79d9672230f21a04580d7ac2f4c3
> > commit: 71458cfc782eafe4b27656e078d379a34e472adf kernel: add support for gcc 5
> > date:   1 year, 2 months ago
> > config: x86_64-randconfig-x006-201551 (attached as .config)
> > reproduce:
> >         git checkout 71458cfc782eafe4b27656e078d379a34e472adf
> >         # save the attached .config to linux build tree
> >         make ARCH=x86_64 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    arch/x86/xen/suspend.c: In function 'xen_arch_pre_suspend':
> > >> arch/x86/xen/suspend.c:70:9: error: implicit declaration of function 'xen_pv_domain' [-Werror=implicit-function-declaration]
> >         if (xen_pv_domain())
> >             ^
> 
> hm, tricky!
> 
> --- a/arch/x86/xen/suspend.c~arch-x86-xen-suspendc-include-xen-xenh
> +++ a/arch/x86/xen/suspend.c
> @@ -1,6 +1,7 @@
>  #include <linux/types.h>
>  #include <linux/tick.h>
>  
> +#include <xen/xen.h>
>  #include <xen/interface/xen.h>
>  #include <xen/grant_table.h>
>  #include <xen/events.h>


Looks like the right fix. David? Boris?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
