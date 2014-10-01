Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 300176B006C
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 11:45:53 -0400 (EDT)
Received: by mail-ie0-f173.google.com with SMTP id tp5so624838ieb.4
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 08:45:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w2si4606168icy.81.2014.10.01.08.45.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 08:45:52 -0700 (PDT)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com>
	<15705.1412070301@turing-police.cc.vt.edu>
	<20140930144854.GA5098@wil.cx>
	<123795.1412088827@turing-police.cc.vt.edu>
	<20140930160841.GB5098@wil.cx>
	<15704.1412109476@turing-police.cc.vt.edu>
	<A8F88370-512D-45D0-8414-C478D64E46E5@dilger.ca>
	<62749.1412113956@turing-police.cc.vt.edu>
Date: Wed, 01 Oct 2014 11:45:47 -0400
In-Reply-To: <62749.1412113956@turing-police.cc.vt.edu> (Valdis Kletnieks's
	message of "Tue, 30 Sep 2014 17:52:36 -0400")
Message-ID: <x49r3yrn68k.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andreas Dilger <adilger@dilger.ca>, Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Valdis.Kletnieks@vt.edu writes:

> As long as we're at it, if we go that route we probably *also* want a
> way for a program to specify it at open() time (for instance, for the
> use of backup programs) - that should minimize the infamous "everything
> runs like a pig after the backup finishes running because  the *useful*
> pages are all cache-cold".

This sounds an awful lot like posix_fadvise' POSIX_FADV_NOREUSE flag.
Whether the implementation lives up to your expectations is another
matter, but at least the interface is already there.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
