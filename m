Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9D7E6B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 17:24:23 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id rs7so80750683lbb.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 14:24:23 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.134])
        by mx.google.com with ESMTPS id x137si27528012wme.107.2016.06.07.14.24.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 14:24:22 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 7/9] generic syscalls: wire up memory protection keys syscalls
Date: Tue, 07 Jun 2016 23:25:20 +0200
Message-ID: <4151348.Xje1rehFl0@wuerfel>
In-Reply-To: <20160607204725.A731CB1E@viggo.jf.intel.com>
References: <20160607204712.594DE00A@viggo.jf.intel.com> <20160607204725.A731CB1E@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com

On Tuesday, June 7, 2016 1:47:25 PM CEST Dave Hansen wrote:
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> These new syscalls are implemented as generic code, so enable
> them for architectures like arm64 which use the generic syscall
> table.
> 
> According to Arnd:
> 
>         Even if the support is x86 specific for the forseeable
>         future, it may be good to reserve the number just in
>         case.  The other architecture specific syscall lists are
>         usually left to the individual arch maintainers, most a
>         lot of the newer architectures share this table.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Arnd Bergmann <arnd@arndb.de>

Acked-by: Arnd Bergmann <arnd@arndb.de>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
