Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C9E116B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 18:46:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o65so24273487qkl.12
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:46:57 -0700 (PDT)
Received: from mail-qt0-f173.google.com (mail-qt0-f173.google.com. [209.85.216.173])
        by mx.google.com with ESMTPS id o94si1682443qte.20.2017.08.16.15.46.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 15:46:57 -0700 (PDT)
Received: by mail-qt0-f173.google.com with SMTP id s6so29131522qtc.1
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 15:46:56 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv2 0/2] Command line randomness
Date: Wed, 16 Aug 2017 15:46:48 -0700
Message-Id: <20170816224650.1089-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Micay <danielmicay@gmail.com>

Hi,

This is a series to add the kernel command line as a source of randomness.
The first patch is an (old) prepatory patch from me to move the stack canary
initialization later. The second patch is from Daniel Micay to actually
add the command line to the pool.

Kees suggested this go through -mm.

Thanks,
Laura

Daniel Micay (1):
  extract early boot entropy from the passed cmdline

Laura Abbott (1):
  init: Move stack canary initialization after setup_arch

 init/main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
