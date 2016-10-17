Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id EA5566B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 11:43:08 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id d186so103526352lfg.7
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 08:43:08 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id s4si42240533wjh.13.2016.10.17.08.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 08:43:07 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] generic syscalls: kill cruft from removed pkey syscalls
Date: Mon, 17 Oct 2016 17:37:29 +0200
Message-ID: <5993847.hpzj164ak1@wuerfel>
In-Reply-To: <20161017151814.1CE8B6C3@viggo.jf.intel.com>
References: <20161017151814.1CE8B6C3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, dave.hansen@linux.intel.com, tglx@linutronix.de, x86@kernel.org, linux-arch@vger.kernel.org, mgorman@techsingularity.net, linux-api@vger.kernel.org, linux-mm@kvack.org, luto@kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Monday, October 17, 2016 8:18:15 AM CEST Dave Hansen wrote:
> 
> pkey_set() and pkey_get() were syscalls present in older versions
> of the protection keys patches.  They were fully excised from the
> x86 code, but some cruft was left in the generic syscall code.  The
> C++ comments were intended to help to make it more glaring to me to
> fix them before actually submitting them.  That technique worked,
> but later than I would have liked.
> 
> I test-compiled this for arm64.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: x86@kernel.org
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-arch@vger.kernel.org
> Cc: mgorman@techsingularity.net
> Cc: linux-api@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: luto@kernel.org
> Cc: akpm@linux-foundation.org
> Cc: torvalds@linux-foundation.org
> Fixes: a60f7b69d92c0 ("generic syscalls: Wire up memory protection keys syscalls")

Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
