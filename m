Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 30F886B0005
	for <linux-mm@kvack.org>; Sun, 12 Jun 2016 00:38:20 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id h68so45630019lfh.2
        for <linux-mm@kvack.org>; Sat, 11 Jun 2016 21:38:20 -0700 (PDT)
Received: from relay6-d.mail.gandi.net (relay6-d.mail.gandi.net. [2001:4b98:c:538::198])
        by mx.google.com with ESMTPS id o82si8141748wmg.65.2016.06.11.21.38.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 11 Jun 2016 21:38:18 -0700 (PDT)
Date: Sat, 11 Jun 2016 21:38:10 -0700
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: undefined reference to `printk'
Message-ID: <20160612043810.GA1326@x>
References: <201606121058.3CeznQLn%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606121058.3CeznQLn%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild test robot <fengguang.wu@intel.com>

[Adding LKML, linux-arch, and Linus.]

On Sun, Jun 12, 2016 at 10:17:01AM +0800, kbuild test robot wrote:
> All errors (new ones prefixed by >>):
> 
>    arch/m32r/kernel/built-in.o: In function `default_eit_handler':
> >> (.text+0x3f8): undefined reference to `printk'
>    arch/m32r/kernel/built-in.o: In function `default_eit_handler':
>    (.text+0x3f8): relocation truncated to fit: R_M32R_26_PCREL_RELA against undefined symbol `printk'

As far as I can tell, there has been a patch available for this for
months, and it still doesn't seem to have been applied anywhere.

m32r is listed in MAINTAINERS as "Orphan", and has been since commit
b4174867bee83e79dc155479cb1b67c452da6476 in 2014.  And that commit
in turn observed no commits from the maintainer since 2009.  Looking at
the log for arch/m32r, I don't see any activity other than random fixes
by others, and based on the signoffs, all of those seem to go through
miscellaneous trees.

Is anyone using m32r?  Is anyone willing to maintain it?  And if not,
should we consider removing it?

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
