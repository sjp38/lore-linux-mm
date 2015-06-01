Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id BC0616B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 14:35:34 -0400 (EDT)
Received: by oihd6 with SMTP id d6so108267028oih.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 11:35:34 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id e75si13798oic.7.2015.06.01.11.35.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 11:35:34 -0700 (PDT)
Message-ID: <1433182554.23540.112.camel@misato.fc.hp.com>
Subject: Re: [PATCH 2/4] x86/pat: Merge pat_init_cache_modes() into its
 caller
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 01 Jun 2015 12:15:54 -0600
In-Reply-To: <20150531102338.GB20440@pd.tnic>
References: <20150531094655.GA20440@pd.tnic>
	 <1433065686-20922-1-git-send-email-bp@alien8.de>
	 <1433065686-20922-2-git-send-email-bp@alien8.de>
	 <20150531102338.GB20440@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: jgross@suse.com, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, arnd@arndb.de, Elliott@hp.com, hch@lst.de, hmh@hmh.eng.br, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, konrad.wilk@oracle.com, linux-mm <linux-mm@kvack.org>, linux-nvdimm@lists.01.org, "Luis R. Rodriguez" <mcgrof@suse.com>, stefan.bader@canonical.com, Thomas Gleixner <tglx@linutronix.de>, x86-ml <x86@kernel.org>, yigal@plexistor.com, lkml <linux-kernel@vger.kernel.org>

On Sun, 2015-05-31 at 12:23 +0200, Borislav Petkov wrote:
> On Sun, May 31, 2015 at 11:48:04AM +0200, Borislav Petkov wrote:
> > From: Borislav Petkov <bp@suse.de>
> > 
> > This way we can pass pat MSR value directly.
> 
> This breaks xen as that function is used there, doh. :-\
> 
> JA 1/4 rgen,
> 
> can you check the enlighten.c changes below please?
> 
> I'm reading xen's PAT config from MSR_IA32_CR_PAT and handing it down to
> pat_init_cache_modes(). That shouldn't change current behavior AFAICT
> because pat_init_cache_modes() did it itself before.
> 
> Right?
> 
> Thanks.
> 
> ---
> Author: Borislav Petkov <bp@suse.de>
> Date:   Sat May 30 13:09:55 2015 +0200
> 
>     x86/pat: Emulate PAT when it is disabled
>     
>     In the case when PAT is disabled on the command line with "nopat" or
>     when virtualization doesn't support PAT (correctly) - see
>     
>       9d34cfdf4796 ("x86: Don't rely on VMWare emulating PAT MSR correctly").
>     
>     we emulate it using the PWT and PCD cache attribute bits. Get rid of
>     boot_pat_state while at it.
>     
>     Based on a conglomerate patch from Toshi Kani.
>     
>     Signed-off-by: Borislav Petkov <bp@suse.de>

Reviewed-by: Toshi Kani <toshi.kani@hp.com>

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
