Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2266B0253
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:38:41 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id d123so167841939pfd.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:38:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r80si5226560pfa.30.2017.02.07.13.38.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 13:38:40 -0800 (PST)
Date: Tue, 7 Feb 2017 13:38:39 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, slab: rename kmalloc-node cache to kmalloc-<size>
Message-Id: <20170207133839.f6b1f1befe4468770991f5e0@linux-foundation.org>
In-Reply-To: <201702080139.e2GzXRQt%fengguang.wu@intel.com>
References: <20170203181008.24898-1-vbabka@suse.cz>
	<201702080139.e2GzXRQt%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Wed, 8 Feb 2017 01:15:17 +0800 kbuild test robot <lkp@intel.com> wrote:

> Hi Vlastimil,
> 
> [auto build test WARNING on mmotm/master]
> [also build test WARNING on v4.10-rc7 next-20170207]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Vlastimil-Babka/mm-slab-rename-kmalloc-node-cache-to-kmalloc-size/20170204-021843
> base:   git://git.cmpxchg.org/linux-mmotm.git master
> config: arm-allyesconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All warnings (new ones prefixed by >>):
> 
> >> WARNING: mm/built-in.o(.text+0x3b49c): Section mismatch in reference from the function get_kmalloc_cache_name() to the (unknown reference) .init.rodata:(unknown)
>    The function get_kmalloc_cache_name() references
>    the (unknown reference) __initconst (unknown).
>    This is often because get_kmalloc_cache_name lacks a __initconst
>    annotation or the annotation of (unknown) is wrong.

yup, thanks.

--- a/mm/slab_common.c~mm-slab-rename-kmalloc-node-cache-to-kmalloc-size-fix
+++ a/mm/slab_common.c
@@ -935,7 +935,7 @@ static struct {
 	{"kmalloc-67108864", 67108864}
 };
 
-const char *get_kmalloc_cache_name(int index)
+const char * __init get_kmalloc_cache_name(int index)
 {
 	return kmalloc_info[index].name;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
