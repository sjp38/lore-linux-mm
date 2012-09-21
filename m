Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 163EB6B0044
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 11:23:55 -0400 (EDT)
Message-ID: <505C865D.5090802@xenotime.net>
Date: Fri, 21 Sep 2012 08:23:09 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
Subject: Re: mmotm 2012-09-20-17-25 uploaded (fs/bimfmt_elf on uml)
References: <20120921002638.7859F100047@wpzn3.hot.corp.google.com>
In-Reply-To: <20120921002638.7859F100047@wpzn3.hot.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Richard Weinberger <richard@nod.at>

On 09/20/2012 05:26 PM, akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2012-09-20-17-25 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 
> mmotm-readme.txt says
> 
> README for mm-of-the-moment:
> 
> http://www.ozlabs.org/~akpm/mmotm/
> 


on uml for x86_64 defconfig:

fs/binfmt_elf.c: In function 'fill_files_note':
fs/binfmt_elf.c:1419:2: error: implicit declaration of function 'vmalloc'
fs/binfmt_elf.c:1419:7: warning: assignment makes pointer from integer without a cast
fs/binfmt_elf.c:1437:5: error: implicit declaration of function 'vfree'


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
