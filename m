Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8AECC6B0253
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 13:40:27 -0500 (EST)
Received: by wmuu63 with SMTP id u63so192411366wmu.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 10:40:27 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id y83si6642394wmb.27.2015.12.08.10.40.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 08 Dec 2015 10:40:26 -0800 (PST)
Date: Tue, 8 Dec 2015 19:39:37 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 25/34] x86, pkeys: add arch_validate_pkey()
In-Reply-To: <20151204011459.CEC0E764@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.11.1512081937470.3595@nanos>
References: <20151204011424.8A36E365@viggo.jf.intel.com> <20151204011459.CEC0E764@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com

On Thu, 3 Dec 2015, Dave Hansen wrote:
> +#define arch_max_pkey() (boot_cpu_has(X86_FEATURE_OSPKE) ?      \
> +				CONFIG_NR_PROTECTION_KEYS : 1)

Should this really be a config option? Can't that value change ?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
