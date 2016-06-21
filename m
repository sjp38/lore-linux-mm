Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA1D16B0005
	for <linux-mm@kvack.org>; Tue, 21 Jun 2016 02:15:24 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id js8so4493964lbc.2
        for <linux-mm@kvack.org>; Mon, 20 Jun 2016 23:15:24 -0700 (PDT)
Received: from 1wt.eu (wtarreau.pck.nerim.net. [62.212.114.60])
        by mx.google.com with ESMTP id j77si29099231lfi.258.2016.06.20.23.15.22
        for <linux-mm@kvack.org>;
        Mon, 20 Jun 2016 23:15:23 -0700 (PDT)
Date: Tue, 21 Jun 2016 08:15:14 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [linux-stable-rc:linux-3.10.y 4/144]
 scripts/asn1_compiler.c:1341:3: warning: enumeration value 'NOT_COMPOUND'
 not handled in switch
Message-ID: <20160621061514.GC19654@1wt.eu>
References: <201606201758.AK7FD0yj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606201758.AK7FD0yj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Philip =?iso-8859-1?Q?M=FCller?= <philm@manjaro.org>

On Mon, Jun 20, 2016 at 05:41:01PM +0800, kbuild test robot wrote:
> Hi,
> 
> First bad commit (maybe != root cause):
> 
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable-rc.git linux-3.10.y
> head:   ca1199fccf14540e86f6da955333e31d6fec5f3e
> commit: a4a4f1cd733fe5b345db4e8cc19bb8868d562a8a [4/144] compiler-gcc: integrate the various compiler-gcc[345].h files
> config: x86_64-randconfig-x014-201625 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         git checkout a4a4f1cd733fe5b345db4e8cc19bb8868d562a8a
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    scripts/asn1_compiler.c: In function 'render_out_of_line_list':
> >> scripts/asn1_compiler.c:1341:3: warning: enumeration value 'NOT_COMPOUND' not handled in switch [-Wswitch]
>       switch (e->compound) {
>       ^~~~~~
> >> scripts/asn1_compiler.c:1341:3: warning: enumeration value 'CHOICE' not handled in switch [-Wswitch]
> >> scripts/asn1_compiler.c:1341:3: warning: enumeration value 'ANY' not handled in switch [-Wswitch]
> >> scripts/asn1_compiler.c:1341:3: warning: enumeration value 'TYPE_REF' not handled in switch [-Wswitch]
> >> scripts/asn1_compiler.c:1341:3: warning: enumeration value 'TAG_OVERRIDE' not handled in switch [-Wswitch]

Fixed by backporting commit eb8948a ("X.509: remove possible code fragility:
enumeration values not handled"). Thanks for reporting.

Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
