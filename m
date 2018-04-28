Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6896B0003
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 04:29:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k27-v6so2732625wre.23
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 01:29:09 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id o204sor794612wme.41.2018.04.28.01.29.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Apr 2018 01:29:08 -0700 (PDT)
Date: Sat, 28 Apr 2018 10:29:04 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
Message-ID: <20180428082904.ekzsbqx3ohqxygbg@gmail.com>
References: <20180427174527.0031016C@viggo.jf.intel.com>
 <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
 <20180428071538.3whanph7r6v56h2a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180428071538.3whanph7r6v56h2a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxram@us.ibm.com, tglx@linutronix.de, dave.hansen@intel.com, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com


* Ingo Molnar <mingo@kernel.org> wrote:

> The hang problem is still there, if I run a script like this:
> 
>  while :; do date; echo -n "32-bit: "; ./protection_keys_32 >/dev/null; date; echo -n "64-bit: "; ./protection_keys_64 >/dev/null; done
> 
> then within a minute one of the testcases hangs reliably.
> 
> Out of 4 attempts so far one hang was in the 32-bit testcase, 3 hangs were in the 
> 64-bit testcase - so 64-bit appears to trigger it more frequently.

Note that even with all fixes in this series applied the self-test hang still 
triggers.

Thanks,

	Ingo
