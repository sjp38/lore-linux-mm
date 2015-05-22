Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id F02F282997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 03:16:04 -0400 (EDT)
Received: by wghq2 with SMTP id q2so9021095wgh.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 00:16:04 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id dl7si2215220wjb.119.2015.05.22.00.16.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 22 May 2015 00:16:03 -0700 (PDT)
Date: Fri, 22 May 2015 09:16:05 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v9 6/10] x86, mm, pat: Add pgprot_writethrough() for WT
In-Reply-To: <1431551151-19124-7-git-send-email-toshi.kani@hp.com>
Message-ID: <alpine.DEB.2.11.1505220915531.5457@nanos>
References: <1431551151-19124-1-git-send-email-toshi.kani@hp.com> <1431551151-19124-7-git-send-email-toshi.kani@hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@ml01.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de

On Wed, 13 May 2015, Toshi Kani wrote:

> This patch adds pgprot_writethrough() for setting WT to a given
> pgprot_t.
> 
> Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Reviewed-by: Thomas Gleixner <tglx@linutronix.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
