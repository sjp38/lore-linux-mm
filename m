Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0C4D6B0008
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 18:01:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id j3so2015479wrb.18
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 15:01:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q190si4393191wmg.51.2018.03.07.15.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 15:01:30 -0800 (PST)
Date: Wed, 7 Mar 2018 15:01:27 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] x86/mm: implement free pmd/pte page interfaces
Message-Id: <20180307150127.1e09e9826e0f2c80ce42fa4d@linux-foundation.org>
In-Reply-To: <20180307183227.17983-3-toshi.kani@hpe.com>
References: <20180307183227.17983-1-toshi.kani@hpe.com>
	<20180307183227.17983-3-toshi.kani@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: mhocko@suse.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@suse.de, catalin.marinas@arm.com, guohanjun@huawei.com, will.deacon@arm.com, wxf.wang@hisilicon.com, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On Wed,  7 Mar 2018 11:32:27 -0700 Toshi Kani <toshi.kani@hpe.com> wrote:

> Implement pud_free_pmd_page() and pmd_free_pte_page() on x86, which
> clear a given pud/pmd entry and free up lower level page table(s).
> Address range associated with the pud/pmd entry must have been purged
> by INVLPG.

OK, now we have implementations which match the naming ;) Again, is a
cc:stable warranted?

Do you have any preferences/suggestions as to which tree these should
be merged through?  You're hitting core, arm and x86.
