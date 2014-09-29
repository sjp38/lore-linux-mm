Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id D6EDD6B0035
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 16:15:01 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id l18so12989744wgh.33
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 13:15:01 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id lb1si18038111wjc.115.2014.09.29.13.15.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 13:15:00 -0700 (PDT)
Date: Mon, 29 Sep 2014 22:15:28 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [RESEND PATCH 2/4] x86: add phys addr validity check for /dev/mem
 mmap
In-Reply-To: <1411990382-11902-3-git-send-email-fhrbata@redhat.com>
Message-ID: <alpine.DEB.2.02.1409292211560.22082@ionos.tec.linutronix.de>
References: <1411990382-11902-1-git-send-email-fhrbata@redhat.com> <1411990382-11902-3-git-send-email-fhrbata@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frantisek Hrbata <fhrbata@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, oleg@redhat.com, kamaleshb@in.ibm.com, hechjie@cn.ibm.com, akpm@linux-foundation.org, dave.hansen@intel.com, dvlasenk@redhat.com, prarit@redhat.com, lwoodman@redhat.com, hannsj_uhl@de.ibm.com, torvalds@linux-foundation.org

On Mon, 29 Sep 2014, Frantisek Hrbata wrote:
> V2: fix pfn check in valid_mmap_phys_addr_range, thanks to Dave Hansen

AFAICT, Dave also asked you to change size_t count into something more
intuitive, i.e. nr_bytes or such.

> +int valid_mmap_phys_addr_range(unsigned long pfn, size_t count)

And right he is. I really had to look twice to see that count is
actually number of bytes and not number of pages, which is what you
expect after pfn.

> +{
> +	return arch_pfn_possible(pfn + (count >> PAGE_SHIFT));
> +}

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
