Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9873A6B0073
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:13:03 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so44445806pad.10
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:13:03 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ce14si11442339pdb.253.2015.01.29.15.13.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:13:02 -0800 (PST)
Date: Thu, 29 Jan 2015 15:13:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 15/17] kernel: add support for .init_array.*
 constructors
Message-Id: <20150129151301.006abdbcf9e0dd136dd6ed2f@linux-foundation.org>
In-Reply-To: <1422544321-24232-16-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-16-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, "open list:GENERIC
 INCLUDE/A..." <linux-arch@vger.kernel.org>

On Thu, 29 Jan 2015 18:11:59 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> KASan uses constructors for initializing redzones for global
> variables. Actually KASan doesn't need priorities for constructors,
> so they were removed from GCC 5.0, but GCC 4.9.2 still generates
> constructors with priorities.

I don't understand this changelog either.  What's wrong with priorities
and what is the patch doing about it?  More details, please.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
