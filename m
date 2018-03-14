Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D44366B0010
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 15:27:35 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g13so2439006wrh.23
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 12:27:35 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id l1si559906edc.306.2018.03.14.12.27.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 14 Mar 2018 12:27:34 -0700 (PDT)
Date: Wed, 14 Mar 2018 20:27:10 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/2] x86/mm: remove pointless checks in vmalloc_fault
In-Reply-To: <20180313170347.3829-3-toshi.kani@hpe.com>
Message-ID: <alpine.DEB.2.21.1803142024540.1946@nanos.tec.linutronix.de>
References: <20180313170347.3829-1-toshi.kani@hpe.com> <20180313170347.3829-3-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mingo@redhat.com, hpa@zytor.com, bp@alien8.de, luto@kernel.org, gratian.crisan@ni.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 13 Mar 2018, Toshi Kani wrote:

> vmalloc_fault() sets user's pgd or p4d from the kernel page table.
> Once it's set, all tables underneath are identical. There is no point
> of following the same page table with two separate pointers and makes
> sure they see the same with BUG().
> 
> Remove the pointless checks in vmalloc_fault(). Also rename the kernel
> pgd/p4d pointers to pgd_k/p4d_k so that their names are consistent in
> the file.

I have no idea to which branch this might apply. The first patch applies
cleanly on linus head, but this one fails in hunk #2 on everything I
tried. Can you please check?

Thanks,

	tglx
