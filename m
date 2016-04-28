Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B450B6B0253
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 11:20:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so169944811pfb.0
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 08:20:32 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id b68si10768899pfb.21.2016.04.28.08.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 08:20:21 -0700 (PDT)
From: Christopher Covington <cov@codeaurora.org>
Subject: VDSO unmap and remap support for additional architectures
Date: Thu, 28 Apr 2016 11:18:52 -0400
Message-Id: <1461856737-17071-1-git-send-email-cov@codeaurora.org>
In-Reply-To: <20151202121918.GA4523@arm.com>
References: <20151202121918.GA4523@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, criu@openvz.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Will Deacon <Will.Deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

Please take a look at the following prototype of sharing the PowerPC
VDSO unmap and remap code with other architectures. I've only hooked
up arm64 to begin with. If folks think this is a reasonable approach I
can work on 32 bit ARM as well. Not hearing back from an earlier
request for guidance [1], I simply dove in and started hacking.
Laurent's test case [2][3] is a compelling illustration of whether VDSO
remap works or not on a given architecture.

1. https://lkml.org/lkml/2016/3/2/225
2. https://lists.openvz.org/pipermail/criu/2015-March/019161.html
3. http://lists.openvz.org/pipermail/criu/attachments/20150318/f02ed9ea/attachment.bin

Thanks,
Christopher Covington

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
