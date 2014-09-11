Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4951F6B0037
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 00:02:11 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8399068pab.4
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 21:02:11 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id go11si27313569pbd.132.2014.09.10.21.02.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Sep 2014 21:02:10 -0700 (PDT)
Message-ID: <54111E99.7080309@zytor.com>
Date: Wed, 10 Sep 2014 21:01:29 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH v2 02/10] x86_64: add KASan support
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-1-git-send-email-a.ryabinin@samsung.com> <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1410359487-31938-3-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>

On 09/10/2014 07:31 AM, Andrey Ryabinin wrote:
> This patch add arch specific code for kernel address sanitizer.
> 
> 16TB of virtual addressed used for shadow memory.
> It's located in range [0xffff800000000000 - 0xffff900000000000]
> Therefore PAGE_OFFSET has to be changed from 0xffff880000000000
> to 0xffff900000000000.

NAK on this.

0xffff880000000000 is the lowest usable address because we have agreed
to leave 0xffff800000000000-0xffff880000000000 for the hypervisor or
other non-OS uses.

Bumping PAGE_OFFSET seems needlessly messy, why not just designate a
zone higher up in memory?

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
