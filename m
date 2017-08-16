Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 841EE6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 19:15:03 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id y65so24528221qka.14
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 16:15:03 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by mx.google.com with ESMTPS id t11si1880284qkg.28.2017.08.16.16.15.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 16:15:02 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id a18so29447767qta.0
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 16:15:02 -0700 (PDT)
From: Laura Abbott <labbott@redhat.com>
Subject: [PATCHv3 0/2] Command line randomness
Date: Wed, 16 Aug 2017 16:14:56 -0700
Message-Id: <20170816231458.2299-1-labbott@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Laura Abbott <labbott@redhat.com>, kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Micay <danielmicay@gmail.com>

Hi,

This is v3 of the series to add the kernel command line as a source
of randomness. The main change from v2 is to correctly place the
command line randomness _before_ the stack canary initialization
so the canary can take advantage of that.

Daniel Micay (1):
  extract early boot entropy from the passed cmdline

Laura Abbott (1):
  init: Move stack canary initialization after setup_arch

 init/main.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

-- 
2.13.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
