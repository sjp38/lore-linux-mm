Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43BE328025A
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 12:42:44 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id bv10so91075545pad.2
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 09:42:44 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id pb1si9297374pac.1.2016.09.28.09.42.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 09:42:43 -0700 (PDT)
Subject: Re: linux-next: Tree for Sep 28 (mm/khugepaged.c)
References: <20160928165618.56208c39@canb.auug.org.au>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <88dcf0bd-90f6-ed22-ddd8-f5e237bedcd6@infradead.org>
Date: Wed, 28 Sep 2016 09:42:40 -0700
MIME-Version: 1.0
In-Reply-To: <20160928165618.56208c39@canb.auug.org.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 09/27/16 23:56, Stephen Rothwell wrote:
> Hi all,
> 
> Changes since 20160927:
> 


on i386, when SYSFS is not enabled (and PROC_FS is not enabled):

mm/built-in.o: In function `khugepaged_defrag_store':
khugepaged.c:(.text+0x58cb7): undefined reference to `single_hugepage_flag_store'
mm/built-in.o: In function `khugepaged_defrag_show':
khugepaged.c:(.text+0x58cc8): undefined reference to `single_hugepage_flag_show'


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
