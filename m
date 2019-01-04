Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 173D18E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:49:52 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id a9so27660348pla.2
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 09:49:52 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id o32si17404229pld.407.2019.01.04.09.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 09:49:50 -0800 (PST)
From: Dave Hansen <dave.hansen@linux.intel.com>
Subject: [RFC][v2] x86: remove Intel MPX
Date: Fri,  4 Jan 2019 09:49:38 -0800
Message-Id: <1546624183-26543-1-git-send-email-dave.hansen@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@intel.com
Cc: x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's a second attempt at MPX removal.  The first one was not friendly
to KVM live migration.  We should probably apply the first two patches
(at least) for 4.20+1.

--

Unfortunately, GCC 9.1 is expected to be be released without support for
MPX.  This means that there was only a relatively small window where
folks could have ever used MPX.  It failed to gain wide adoption in the
industry, and Linux was the only mainstream OS to ever support it widely.

Support for the feature may also disappear on future processors.

The benefits of keeping the feature in the tree is not worth the ongoing
maintenance cost.  This is an incremental, bisectable, set that removes
MPX bit by bit.  The only MPX code left in the kernel is the XSAVE state
management which is currently still needed for guests that might use MPX.
Keeping this code prevents breaking live migration between kernels which
have MPX removed versus present.

It was a fun run, but it's time for it to go.  Adios, MPX!

Cc: x86@kernel.org
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
