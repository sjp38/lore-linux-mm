Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id 798FA6B006E
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 12:09:56 -0400 (EDT)
Received: by oihd6 with SMTP id d6so105188574oih.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:09:56 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id u14si9064715oie.102.2015.06.01.09.09.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 09:09:55 -0700 (PDT)
Message-ID: <1433173815.23540.110.camel@misato.fc.hp.com>
Subject: Re: [PATCH v11 2/12] x86, mm, pat: Refactor !pat_enabled handling
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 01 Jun 2015 09:50:15 -0600
In-Reply-To: <20150531094655.GA20440@pd.tnic>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
	 <1432940350-1802-3-git-send-email-toshi.kani@hp.com>
	 <20150531094655.GA20440@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Sun, 2015-05-31 at 11:46 +0200, Borislav Petkov wrote:
> On Fri, May 29, 2015 at 04:59:00PM -0600, Toshi Kani wrote:
> > From: Toshi Kani <toshi.kani@hp.com>
> > 
> > This patch refactors the !pat_enabled code paths and integrates
> > them into the PAT abstraction code.  The PAT table is emulated by
> > corresponding to the two cache attribute bits, PWT (Write Through)
> > and PCD (Cache Disable).  The emulated PAT table is the same as the
> > BIOS default setup when the system has PAT but the "nopat" boot
> > option is specified.  The emulated PAT table is also used when
> > MSR_IA32_CR_PAT returns 0 -- 9d34cfdf4796 ("x86: Don't rely on
> > VMWare emulating PAT MSR correctly").
> 
> To be honest, I wasn't surprised when you sent me the same patch and
> ignored most of my comments. For the future, please let me know if I'm
> wasting my time with commenting on your stuff so that I can plan my work
> and not waste time and energy reviewing, ok?

I apologize that I overlooked a comment requesting to divide this
refactor patch into smaller patches.

> Unfortunately, if you want something done right, you have to do it
> yourself.
>
> So I did that, I split that ugly cleanup into something much more
> readable, patches as a reply to this message.
> 
> Feel free to base your work ontop of
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/bp/bp.git#tip-mm-2
> 

I will look into your changes, and rebase the patchset.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
