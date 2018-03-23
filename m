Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A8F076B0009
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:46:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id bd8-v6so8079089plb.20
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:46:50 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id q4-v6si8710399plr.365.2018.03.23.10.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:46:49 -0700 (PDT)
Subject: [PATCH 00/11] Use global pages with PTI
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 10:44:47 -0700
Message-Id: <20180323174447.55F35636@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com

The later verions of the KAISER pathces (pre-PTI) allowed the user/kernel
shared areas to be GLOBAL.  The thought was that this would reduce the
TLB overhead of keeping two copies of these mappings.

During the switch over to PTI, we seem to have lost our ability to have
GLOBAL mappings.  This adds them back.

This adds one major change from the last version of the patch set
(present in the last patch).  It makes all kernel text global for non-
PCID systems.  This keeps kernel data protected always, but means that
it will be easier to find kernel gadgets via meltdown on old systems
without PCIDs.  This heuristic is, I think, a reasonable one and it
keeps us from having to create any new pti=foo options

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>
