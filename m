Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id F24596B0038
	for <linux-mm@kvack.org>; Fri, 12 Sep 2014 14:42:44 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id em10so1208824wid.3
        for <linux-mm@kvack.org>; Fri, 12 Sep 2014 11:42:43 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id m9si4395864wiv.5.2014.09.12.11.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 12 Sep 2014 11:42:41 -0700 (PDT)
Date: Fri, 12 Sep 2014 20:42:23 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v8 08/10] x86, mpx: add prctl commands PR_MPX_REGISTER,
 PR_MPX_UNREGISTER
In-Reply-To: <alpine.DEB.2.10.1409121812550.4178@nanos>
Message-ID: <alpine.DEB.2.10.1409122038590.4178@nanos>
References: <1410425210-24789-1-git-send-email-qiaowei.ren@intel.com> <1410425210-24789-9-git-send-email-qiaowei.ren@intel.com> <alpine.DEB.2.10.1409120020060.4178@nanos> <541239F1.2000508@intel.com> <alpine.DEB.2.10.1409120950260.4178@nanos>
 <alpine.DEB.2.10.1409121120440.4178@nanos> <5413050A.1090307@intel.com> <alpine.DEB.2.10.1409121812550.4178@nanos>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Sep 2014, Thomas Gleixner wrote:
> On Fri, 12 Sep 2014, Dave Hansen wrote:
> The proper solution to this problem is:
> 
>     do_bounds()
> 	bd_addr = get_bd_addr_from_xsave();
> 	bd_entry = bndstatus & ADDR_MASK:

Just for clarification. You CANNOT avoid the xsave here because it's
the only way to access BNDSTATUS according to the manual.

"The BNDCFGU and BNDSTATUS registers are accessible only with
 XSAVE/XRSTOR family of instructions"

So there is no point to cache BNDCFGU as you get it anyway when you
need to retrieve the invalid BD entry.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
