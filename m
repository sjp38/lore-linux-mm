Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AF5286B0253
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 15:26:16 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ib6so97034108pad.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 12:26:16 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id yw7si1210495pac.85.2016.07.08.12.26.14
        for <linux-mm@kvack.org>;
        Fri, 08 Jul 2016 12:26:15 -0700 (PDT)
Subject: Re: [PATCH 6/9] x86, pkeys: add pkey set/get syscalls
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124728.C1116BB1@viggo.jf.intel.com>
 <20160707144508.GZ11498@techsingularity.net> <577E924C.6010406@sr71.net>
 <20160708071810.GA27457@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <577FFE55.7040209@sr71.net>
Date: Fri, 8 Jul 2016 12:26:13 -0700
MIME-Version: 1.0
In-Reply-To: <20160708071810.GA27457@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On 07/08/2016 12:18 AM, Ingo Molnar wrote:
> So my hope was that we'd also grow some debugging features: such as a periodic 
> watchdog timer clearing all non-allocated pkeys of a task and re-setting them to 
> their (kernel-)known values and thus forcing user-space to coordinate key 
> allocation/freeing.

I'm glad you mentioned this.  I've explicitly called out this behavior
in the manpages now, or at least called out the fact that the kernel
will not preserve PKRU contents for unallocated keys.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
