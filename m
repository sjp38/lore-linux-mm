Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A191800D8
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 22:34:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id r6so2000216pfk.9
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 19:34:42 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id n9-v6si3007632plk.311.2018.01.21.19.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 21 Jan 2018 19:34:40 -0800 (PST)
In-Reply-To: <1516326648-22775-4-git-send-email-linuxram@us.ibm.com>
From: Michael Ellerman <patch-notifications@ellerman.id.au>
Subject: Re: [v10,03/27] powerpc: initial pkey plumbing
Message-Id: <3zPxrB60pxz9sNx@ozlabs.org>
Date: Mon, 22 Jan 2018 14:34:33 +1100 (AEDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linux-arch@vger.kernel.org, ebiederm@xmission.com, linux-doc@vger.kernel.org, x86@kernel.org, dave.hansen@intel.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, linux-kselftest@vger.kernel.org, bauerman@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, khandual@linux.vnet.ibm.com

On Fri, 2018-01-19 at 01:50:24 UTC, Ram Pai wrote:
> Basic  plumbing  to   initialize  the   pkey  system.
> Nothing is enabled yet. A later patch will enable it
> once all the infrastructure is in place.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>

Patches 3-27 applied to powerpc next, thanks.

https://git.kernel.org/powerpc/c/92e3da3cf193fd27996909956c12a2

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
