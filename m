Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E2BFD6B0038
	for <linux-mm@kvack.org>; Sat,  1 Aug 2015 12:33:14 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so66108854wib.1
        for <linux-mm@kvack.org>; Sat, 01 Aug 2015 09:33:14 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id cg18si15687602wjb.154.2015.08.01.09.33.12
        for <linux-mm@kvack.org>;
        Sat, 01 Aug 2015 09:33:13 -0700 (PDT)
Date: Sat, 1 Aug 2015 18:33:11 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [tip:x86/mm] x86/mm/mtrr: Clean up mtrr_type_lookup()
Message-ID: <20150801163311.GA15356@nazgul.tnic>
References: <1431714237-880-6-git-send-email-toshi.kani@hp.com>
 <1432628901-18044-6-git-send-email-bp@alien8.de>
 <tip-0cc705f56e400764a171055f727d28a48260bb4b@git.kernel.org>
 <20150731131802.GW25159@twins.programming.kicks-ass.net>
 <20150731144452.GA8106@nazgul.tnic>
 <20150731150806.GX25159@twins.programming.kicks-ass.net>
 <20150731152713.GA9756@nazgul.tnic>
 <20150801142820.GU30479@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150801142820.GU30479@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Peter Zijlstra <peterz@infradead.org>, mingo@kernel.org, hpa@zytor.com, dvlasenk@redhat.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tglx@linutronix.de, linux-mm@kvack.org, luto@amacapital.net, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-tip-commits@vger.kernel.org

On Sat, Aug 01, 2015 at 04:28:20PM +0200, Luis R. Rodriguez wrote:
> I need to update this documentation to remove set_memory_wc() there as we've
> learned with the MTRR --> PAT conversion that set_memory_wc() cannot be used on
> IO memory, it can only be used for RAM. I am not sure if I would call it being
> broken that you cannot use set_memory_*() for IO memory that may have been by
> design.

Well, it doesn't really make sense to write-combine IO memory, does it?
My simplistic impression is that an IO range behind which there's a
device, cannot stomach any caching of IO as all commands/data accesses
need to happen as they get issued...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
