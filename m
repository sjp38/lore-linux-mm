Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 229BE6B00FE
	for <linux-mm@kvack.org>; Mon,  3 Nov 2014 12:14:51 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so7104850wib.11
        for <linux-mm@kvack.org>; Mon, 03 Nov 2014 09:14:50 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id e17si9107941wiw.45.2014.11.03.09.14.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 03 Nov 2014 09:14:50 -0800 (PST)
Date: Mon, 3 Nov 2014 18:14:37 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/7] x86, mm, pat: Set WT to PA7 slot of PAT MSR
In-Reply-To: <1414450545-14028-2-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1411031812390.5308@nanos>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com> <1414450545-14028-2-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com

On Mon, 27 Oct 2014, Toshi Kani wrote:
> +	} else {
> +		/*
> +		 * PAT full support. WT is set to slot 7, which minimizes
> +		 * the risk of using the PAT bit as slot 3 is UC and is
> +		 * currently unused. Slot 4 should remain as reserved.

This comment makes no sense. What minimizes which risk and what has
this to do with slot 3 and slot 4?

> +		 *
> +		 *  PTE encoding used in Linux:
> +		 *      PAT
> +		 *      |PCD
> +		 *      ||PWT  PAT
> +		 *      |||    slot
> +		 *      000    0    WB : _PAGE_CACHE_MODE_WB
> +		 *      001    1    WC : _PAGE_CACHE_MODE_WC
> +		 *      010    2    UC-: _PAGE_CACHE_MODE_UC_MINUS
> +		 *      011    3    UC : _PAGE_CACHE_MODE_UC
> +		 *      100    4    <reserved>
> +		 *      101    5    <reserved>
> +		 *      110    6    <reserved>

Well, they are still mapped to WB/WC/UC_MINUS ....

> +		 *      111    7    WT : _PAGE_CACHE_MODE_WT
> +		 */
> +		pat = PAT(0, WB) | PAT(1, WC) | PAT(2, UC_MINUS) | PAT(3, UC) |
> +		      PAT(4, WB) | PAT(5, WC) | PAT(6, UC_MINUS) | PAT(7, WT);
> +	}

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
