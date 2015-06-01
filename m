Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id F32B56B006E
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 05:19:45 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so69107167wic.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 02:19:45 -0700 (PDT)
Received: from lb2-smtp-cloud6.xs4all.net (lb2-smtp-cloud6.xs4all.net. [194.109.24.28])
        by mx.google.com with ESMTPS id fj6si17613635wib.55.2015.06.01.02.19.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 02:19:45 -0700 (PDT)
Message-ID: <1433150379.2361.46.camel@x220>
Subject: Re: [PATCH v2 4/4] arch, x86: cache management apis for persistent
 memory
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 01 Jun 2015 11:19:39 +0200
In-Reply-To: <20150530185940.32590.37804.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <20150530185940.32590.37804.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, hmh@hmh.eng.br, tj@kernel.org, hch@lst.de

On Sat, 2015-05-30 at 14:59 -0400, Dan Williams wrote:
> --- a/lib/Kconfig
> +++ b/lib/Kconfig

> +config ARCH_HAS_PMEM_API
> +	def_bool n

'n' is the default anyway, so I think 

config ARCH_HAS_PMEM_API
	bool

should work just as well.


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
