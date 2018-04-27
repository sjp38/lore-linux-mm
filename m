Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB436B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 13:49:48 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o9-v6so2124761pgv.8
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 10:49:48 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m32-v6si1653202pld.459.2018.04.27.10.49.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Apr 2018 10:49:46 -0700 (PDT)
Subject: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 27 Apr 2018 10:45:27 -0700
Message-Id: <20180427174527.0031016C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com

Hi x86 maintainers,

This set is basically unchanged from the last post.  There was
some previous discussion about other ways to fix this with the ppc
folks (Ram Pai), but we've concluded that this x86-specific fix is
fine.  I think Ram had a different fix for ppc.

Changes from v2:
 * Clarified commit message in patch 1/9 taking some feedback from
   Shuah.

Changes from v1:
 * Added Fixes: and cc'd stable.  No code changes.

--

This fixes two bugs, and adds selftests to make sure they stay fixed:

1. pkey 0 was not usable via mprotect_pkey() because it had never
   been explicitly allocated.
2. mprotect(PROT_EXEC) memory could sometimes be left with the
   implicit exec-only protection key assigned.

I already posted #1 previously.  I'm including them both here because
I don't think it's been picked up in case folks want to pull these
all in a single bundle.

Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>p
Cc: Shuah Khan <shuah@kernel.org>
Cc: Shakeel Butt <shakeelb@google.com>
