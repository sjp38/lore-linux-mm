Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id 201166B0035
	for <linux-mm@kvack.org>; Wed,  8 Jan 2014 09:14:54 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id t59so399943yho.20
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 06:14:53 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id r46si980355yhm.272.2014.01.08.06.14.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jan 2014 06:14:52 -0800 (PST)
Date: Thu, 9 Jan 2014 01:14:29 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Message-ID: <20140109011429.61ce8545@kryten>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D453A4E@AcuExch.aculab.com>
References: <20140107132100.5b5ad198@kryten>
	<063D6719AE5E284EB5DD2968C1650D6D453A4E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>
Cc: "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "penberg@kernel.org" <penberg@kernel.org>, "mpm@selenic.com" <mpm@selenic.com>, "nacc@linux.vnet.ibm.com" <nacc@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>


Hi David,

> Why not just delete the entire test?
> Presumably some time a little earlier no local memory was available.
> Even if there is some available now, it is very likely that some won't
> be available again in the near future.

I agree, the current behaviour seems strange but it has been around
since the inital slub commit.

Anton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
