Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B1FE46B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 15:39:34 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o185so5810034pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 12:39:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id sk8si11578402pac.44.2016.01.27.12.39.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 12:39:34 -0800 (PST)
Date: Wed, 27 Jan 2016 12:39:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 0/8] Support for transparent PUD pages for DAX files
Message-Id: <20160127123933.bcfef2fe5bcdc5bb6714eec7@linux-foundation.org>
In-Reply-To: <20160127123131.2be09678d5b477386497ade7@linux-foundation.org>
References: <1452282592-27290-1-git-send-email-matthew.r.wilcox@intel.com>
	<20160127123131.2be09678d5b477386497ade7@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <matthew.r.wilcox@intel.com>, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Wed, 27 Jan 2016 12:31:31 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> Just from eyeballing the patches, I'm expecting build errors ;)

Didn't take long :(

mm/memory.c: In function 'zap_pud_range':
mm/memory.c:1216: error: implicit declaration of function 'pud_trans_huge'
mm/memory.c:1217: error: 'HPAGE_PUD_SIZE' undeclared (first use in this function)

and, midway:

include/linux/mm.h:348: error: redefinition of 'pud_devmap'
include/asm-generic/pgtable.h:684: note: previous definition of 'pud_devmap' was here

Please run x86_64 allnoconfig at each step of the series, fix and
respin?  It only takes 30s to compile.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
