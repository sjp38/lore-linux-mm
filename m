Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 377046B00AC
	for <linux-mm@kvack.org>; Mon, 25 May 2015 06:05:30 -0400 (EDT)
Received: by wizk4 with SMTP id k4so43495173wiz.1
        for <linux-mm@kvack.org>; Mon, 25 May 2015 03:05:29 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id em3si11788633wib.90.2015.05.25.03.05.28
        for <linux-mm@kvack.org>;
        Mon, 25 May 2015 03:05:28 -0700 (PDT)
Date: Mon, 25 May 2015 13:05:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [BUG] Read-Only THP causes stalls (commit 10359213d)
Message-ID: <20150525100515.GA8275@node.dhcp.inet.fi>
References: <20150524193404.GD16910@cbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150524193404.GD16910@cbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoffer Dall <christoffer.dall@linaro.org>
Cc: linux-mm@kvack.org, ebru.akagunduz@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill.shutemov@linux.intel.com, riel@redhat.com, vbabka@suse.cz, zhangyanfei@cn.fujitsu.com, aarcange@redhat.com, Will Deacon <will.deacon@arm.com>, Andre Przywara <andre.przywara@arm.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org

On Sun, May 24, 2015 at 09:34:04PM +0200, Christoffer Dall wrote:
> Hi all,
> 
> I noticed a regression on my arm64 APM X-Gene system a couple
> of weeks back.  I would occassionally see the system lock up and see RCU
> stalls during the caching phase of kernbench.  I then wrote a small
> script that does nothing but cache the files
> (http://paste.ubuntu.com/11324767/) and ran that in a loop.  On a known
> bad commit (v4.1-rc2), out of 25 boots, I never saw it get past 21
> iterations of the loop.  I have since tried to run a bisect from v3.19 to
> v4.0 using 100 iterations as my criteria for a good commit.
> 
> This resulted in the following first bad commit:
> 
> 10359213d05acf804558bda7cc9b8422a828d1cd
> (mm: incorporate read-only pages into transparent huge pages, 2015-02-11)
> 
> Indeed, running the workload on v4.1-rc4 still produced the behavior,
> but reverting the above commit gets me through 100 iterations of the
> loop.
> 
> I have not tried to reproduce on an x86 system.  Turning on a bunch
> of kernel debugging features *seems* to hide the problem.  My config for
> the XGene system is defconfig + CONFIG_BRIDGE and
> CONFIG_POWER_RESET_XGENE.
> 
> Please let me know if I can help test patches or other things I can
> do to help.  I'm afraid that by simply reading the patch I didn't see
> anything obviously wrong with it which would cause this behavior.

I don't see the problem on x86.

Some backtraces could help to track it down.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
