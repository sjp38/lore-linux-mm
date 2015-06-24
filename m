Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 12A8E6B006C
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 08:36:09 -0400 (EDT)
Received: by wiga1 with SMTP id a1so134363614wig.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 05:36:08 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id d6si13525478wjy.185.2015.06.24.05.36.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 24 Jun 2015 05:36:08 -0700 (PDT)
Message-ID: <558AA42B.2050505@nod.at>
Date: Wed, 24 Jun 2015 14:35:55 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH v5 6/6] arch, x86: pmem api for ensuring durability of
 persistent memory updates
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com> <20150622161754.GC8240@lst.de> <5589374D.9060009@nod.at> <20150624120820.GA17542@lst.de>
In-Reply-To: <20150624120820.GA17542@lst.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org

Am 24.06.2015 um 14:08 schrieb Christoph Hellwig:
> On Tue, Jun 23, 2015 at 12:39:09PM +0200, Richard Weinberger wrote:
>> Not sure if I understand this correctly, is the plan to support pmem also on UML?
>> At least drivers/block/pmem.c cannot work on UML as it depends on io memory.
>>
>> Only x86 seems to have ARCH_HAS_NOCACHE_UACCESS, if UML would offer these methods
>> what drivers need them? I'm still not sure where it would make sense on UML as
>> uaccess on UML means ptrace() between host and guest process.
> 
> Ok, that makese snese.  Dan, how about just moving the new pmem helpers
> from cacheflush.h to a new asm/pmem.h to avoid having them dragged into
> the um build?

If UML does not build for whatever reason, please CC me.
I'll happily help out. Historically UML includes a lot stuff
it should not. So, untangling header dependencies does often
wonders. :-)

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
