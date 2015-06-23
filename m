Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8CB786B0071
	for <linux-mm@kvack.org>; Tue, 23 Jun 2015 06:39:21 -0400 (EDT)
Received: by wgbhy7 with SMTP id hy7so5747280wgb.2
        for <linux-mm@kvack.org>; Tue, 23 Jun 2015 03:39:20 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id ce9si10305240wib.4.2015.06.23.03.39.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Jun 2015 03:39:19 -0700 (PDT)
Message-ID: <5589374D.9060009@nod.at>
Date: Tue, 23 Jun 2015 12:39:09 +0200
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [PATCH v5 6/6] arch, x86: pmem api for ensuring durability of
 persistent memory updates
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com> <20150622082449.35954.91411.stgit@dwillia2-desk3.jf.intel.com> <20150622161754.GC8240@lst.de>
In-Reply-To: <20150622161754.GC8240@lst.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>
Cc: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org

Am 22.06.2015 um 18:17 schrieb Christoph Hellwig:
>> +#ifdef ARCH_HAS_NOCACHE_UACCESS
> 
> Seems like this is always define for x86 anyway?
> 
>> +/**
>> + * arch_memcpy_to_pmem - copy data to persistent memory
>> + * @dst: destination buffer for the copy
>> + * @src: source buffer for the copy
>> + * @n: length of the copy in bytes
>> + *
>> + * Copy data to persistent memory media via non-temporal stores so that
>> + * a subsequent arch_wmb_pmem() can flush cpu and memory controller
>> + * write buffers to guarantee durability.
>> + */
> static inline void arch_memcpy_to_pmem(void __pmem *dst, const void *src, size_t n)
> 
> Too long line.  Also why not simply arch_copy_{from,to}_pmem?
> 
>> +#else /* ARCH_HAS_NOCACHE_UACCESS i.e. ARCH=um */
> 
> Oh, UM.  I'd rather see UM fixed to provide these.
> 
> Richard, any chance you could look into it?

Not sure if I understand this correctly, is the plan to support pmem also on UML?
At least drivers/block/pmem.c cannot work on UML as it depends on io memory.

Only x86 seems to have ARCH_HAS_NOCACHE_UACCESS, if UML would offer these methods
what drivers need them? I'm still not sure where it would make sense on UML as
uaccess on UML means ptrace() between host and guest process.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
