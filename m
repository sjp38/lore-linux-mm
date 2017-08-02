Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9564D6B0557
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 01:01:29 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h89so8397638lfi.11
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 22:01:29 -0700 (PDT)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id q12si12280440lfa.619.2017.08.01.22.01.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 22:01:27 -0700 (PDT)
Date: Wed, 2 Aug 2017 07:01:23 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [mmotm:master 50/189] include/linux/swapops.h:220:9: error:
 implicit declaration of function '__pmd'
Message-ID: <20170802050123.GA23155@ravnborg.org>
References: <201708011949.LtRajyO5%fengguang.wu@intel.com>
 <20170801143853.f210976a43d009dba1eeb0db@linux-foundation.org>
 <3B5D0C56-FCBC-4911-9BE8-9CA895CBE49F@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B5D0C56-FCBC-4911-9BE8-9CA895CBE49F@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>, sparclinux@vger.kernel.org

Hi Yan Zin.
> 
> I saw __pmd() was deleted at commit 6e6e41879: sparc32: fix build with STRICT_MM_TYPECHECKS.
> It was commented out at least since 2008, before commit a439fe51a.
> 
> Is there any way to bring it back? Since __pmd() can help us work around a GCC zero initializer bug.

Just send a patch to sparclinux, with a proper commit message
that captures the details why it is required.

Please do not wait for me to do it, as that may take a few days
since I have not looked up all the history why it is needed.

In other words, the code change is trivial, it will more
time to explain *why* it is re-introduced.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
