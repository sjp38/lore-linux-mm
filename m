Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A06126B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:25:18 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id m3so3917955pgd.20
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:25:18 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f20-v6si2996142plj.254.2018.02.15.05.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:25:17 -0800 (PST)
Subject: [PATCH 0/3] Use global pages with PTI
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 15 Feb 2018 05:20:53 -0800
Message-Id: <20180215132053.6C9B48C8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org

The later verions of the KAISER pathces (pre-PTI) allowed the user/kernel
shared areas to be GLOBAL.  The thought was that this would reduce the
TLB overhead of keeping two copies of these mappings.

During the switch over to PTI, we seem to have lost our ability to have
GLOBAL mappings.  This adds them back.

Did we have some reason for leaving out global pages entirely?  We
_should_ have all the TLB flushing mechanics in place to handle these
already since all of our kernel mapping changes have to know how to
flush global pages regardless.

Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
