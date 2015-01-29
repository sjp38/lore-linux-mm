Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 908366B0072
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:40:02 -0500 (EST)
Received: by mail-lb0-f176.google.com with SMTP id z12so29383569lbi.7
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:40:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id au9si15389981wjc.87.2015.01.29.07.40.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 Jan 2015 07:40:00 -0800 (PST)
Message-ID: <54CA544B.1070205@suse.cz>
Date: Thu, 29 Jan 2015 16:39:55 +0100
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH v10 01/17] Add kernel address sanitizer infrastructure.
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com> <1422544321-24232-2-git-send-email-a.ryabinin@samsung.com>
In-Reply-To: <1422544321-24232-2-git-send-email-a.ryabinin@samsung.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, open@kvack.org, list@kvack.org, DOCUMENTATION <linux-doc@vger.kernel.org>, "open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>

On 2015-01-29 16:11, Andrey Ryabinin wrote:
> Kernel Address sanitizer (KASan) is a dynamic memory error detector. It provides
> fast and comprehensive solution for finding use-after-free and out-of-bounds bugs.
> 
> KASAN uses compile-time instrumentation for checking every memory access,
> therefore GCC >= v4.9.2 required.
> 
> This patch only adds infrastructure for kernel address sanitizer. It's not
> available for use yet. The idea and some code was borrowed from [1].

For the kbuild bits, you can add

  Acked-by: Michal Marek <mmarek@suse.cz>

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
