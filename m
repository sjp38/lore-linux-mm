Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 53ECE6B0253
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 09:14:54 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id p190so3266014wmd.0
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 06:14:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c27sor874573wrg.13.2018.01.12.06.14.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 12 Jan 2018 06:14:53 -0800 (PST)
Date: Fri, 12 Jan 2018 15:14:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [REGRESSION] testing/selftests/x86/ pkeys build failures (was:
 Re: [PATCH] mm, x86: pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics)
Message-ID: <20180112141449.5gmn3nxvosk6y6qs@gmail.com>
References: <360ef254-48bc-aee6-70f9-858f773b8693@redhat.com>
 <20180112125537.bdl376ziiaqp664o@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180112125537.bdl376ziiaqp664o@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, linux-x86_64@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, x86@kernel.org, Dave Hansen <dave.hansen@intel.com>, Ram Pai <linuxram@us.ibm.com>


* Ingo Molnar <mingo@kernel.org> wrote:

> Also, the protection keys testcase first need to be fixed, before we complicate 
> them - for example on a pretty regular Ubuntu x86-64 installation they fail to 
> build with the build errors attached further below.
> 
> On an older Fedora 23 installation, the testcases themselves don't build at all:

The Ubuntu build failure seems to have gone away after a 'make clean', what 
remains is an ugly build warning:

triton:~/tip/tools/testing/selftests/x86> make
gcc -m32 -o /home/mingo/tip/tools/testing/selftests/x86/protection_keys_32 -O2 -g -std=gnu99 -pthread -Wall -no-pie  protection_keys.c -lrt -ldl -lm
protection_keys.c: In function a??dumpita??:
protection_keys.c:419:3: warning: ignoring return value of a??writea??, declared with attribute warn_unused_result [-Wunused-result]
   write(1, buf, nr_read);
   ^~~~~~~~~~~~~~~~~~~~~~
gcc -m64 -o /home/mingo/tip/tools/testing/selftests/x86/protection_keys_64 -O2 -g -std=gnu99 -pthread -Wall -no-pie  protection_keys.c -lrt -ldl
protection_keys.c: In function a??dumpita??:
protection_keys.c:419:3: warning: ignoring return value of a??writea??, declared with attribute warn_unused_result [-Wunused-result]
   write(1, buf, nr_read);
   ^~~~~~~~~~~~~~~~~~~~~~

If this build warning and the Fedora build failure is fixed we can apply your 
patch too I think.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
