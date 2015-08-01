Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id B41C56B0038
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 10:28:24 -0400 (EDT)
Received: by wicmv11 with SMTP id mv11so87746991wic.0
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 07:28:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba10si3790760wib.29.2015.08.01.07.28.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 01 Aug 2015 07:28:22 -0700 (PDT)
Date: Sat, 1 Aug 2015 16:28:20 +0200
From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Message-ID: <20150801142820.GU30479@wotan.suse.de>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
 <20150731131802.GW25159@twins.programming.kicks-ass.net>
 <20150731144452.GA8106@nazgul.tnic>
 <20150731150806.GX25159@twins.programming.kicks-ass.net>
 <20150731152713.GA9756@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150731152713.GA9756@nazgul.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Toshi Kani <toshi.kani@hp.com>
Cc: Peter Zijlstra <peterz@infradead.org>, mingo@kernel.org, hpa@zytor.com, dvlasenk@redhat.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, luto@amacapital.net, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org

On Fri, Jul 31, 2015 at 05:27:13PM +0200, Borislav Petkov wrote:
> On Fri, Jul 31, 2015 at 05:08:06PM +0200, Peter Zijlstra wrote:
> > But its things like set_memory_XX(), and afaict that's all buggy against
> > MTRR modifications.
> 
> I think the idea is to not do any MTRR modifications at some point:
> 
> From Documentation/x86/pat.txt:
> 
> "... Ideally mtrr_add() usage will be phased out in favor of
> arch_phys_wc_add() which will be a no-op on PAT enabled systems. The
> region over which a arch_phys_wc_add() is made, should already have been
> ioremapped with WC attributes or PAT entries, this can be done by using
> ioremap_wc() / set_memory_wc()."

I need to update this documentation to remove set_memory_wc() there as we've
learned with the MTRR --> PAT conversion that set_memory_wc() cannot be used on
IO memory, it can only be used for RAM. I am not sure if I would call it being
broken that you cannot use set_memory_*() for IO memory that may have been by
design.

  Luis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
