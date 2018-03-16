Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8AFB16B0025
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 17:48:31 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b2-v6so6184833plz.17
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:48:31 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r26si262548pgu.422.2018.03.16.14.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 14:48:30 -0700 (PDT)
Subject: [PATCH 0/3] x86, pkeys: make pkey 0 more normal
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 16 Mar 2018 14:46:54 -0700
Message-Id: <20180316214654.895E24EC@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

This restores pkey 0 to more of a state of normalcy and adds a
new test in the pkeys selftest to make sure it stays that way.

Cc: Ram Pai <linuxram@us.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Michael Ellermen <mpe@ellerman.id.au>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>p
Cc: Shuah Khan <shuah@kernel.org>
