Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f51.google.com (mail-qa0-f51.google.com [209.85.216.51])
	by kanga.kvack.org (Postfix) with ESMTP id 262136B0038
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 16:07:53 -0400 (EDT)
Received: by mail-qa0-f51.google.com with SMTP id k15so2846898qaq.24
        for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:07:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o80si10227093qge.76.2014.10.16.13.07.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 13:07:52 -0700 (PDT)
Date: Thu, 16 Oct 2014 16:07:42 -0400 (EDT)
Message-Id: <20141016.160742.1639247937393238792.davem@redhat.com>
Subject: Re: unaligned accesses in SLAB etc.
From: David Miller <davem@redhat.com>
In-Reply-To: <alpine.LRH.2.11.1410160956090.13273@adalberg.ut.ee>
References: <alpine.LRH.2.11.1410150012001.11850@adalberg.ut.ee>
	<20141014.173246.921084057467310731.davem@davemloft.net>
	<alpine.LRH.2.11.1410160956090.13273@adalberg.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mroos@linux.ee
Cc: iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

From: Meelis Roos <mroos@linux.ee>
Date: Thu, 16 Oct 2014 10:02:57 +0300 (EEST)

> scripts/Makefile.build:352: recipe for target 'sound/modules.order' failed
> make[1]: *** [sound/modules.order] Bus error
> make[1]: *** Deleting file 'sound/modules.order'
> Makefile:929: recipe for target 'sound' failed

I just reproduced this on my Sun Blade 2500, so it can trigger on UltraSPARC-IIIi
systems too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
