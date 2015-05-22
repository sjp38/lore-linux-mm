Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF1282997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:01:34 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so8650038wgb.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:01:33 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id fk5si5930059wib.21.2015.05.22.00.01.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:01:32 -0700 (PDT)
Date: Fri, 22 May 2015 09:01:34 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 2/10] x86, mm, pat: Change reserve_memtype() for WT
In-Reply-To: <1431551151-19124-3-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220901210.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-3-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:

> This patch changes reserve_memtype() to support the WT cache mode
> with PAT.  When PAT is not enabled, WB and UC- are the only types
> supported.
> 
> When a target range is in RAM, reserve_ram_pages_type() verifies
> the requested type.  reserve_ram_pages_type() is changed to fail
> WT and WP requests with -EINVAL since set_page_memtype() is
> limited to handle three types, WB, WC and UC-.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
