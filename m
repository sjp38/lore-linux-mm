Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 256F36B0008
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 07:31:05 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id f124-v6so1555973wme.5
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 04:31:05 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id m3-v6si12691939wrw.116.2018.10.02.04.31.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 02 Oct 2018 04:31:03 -0700 (PDT)
Date: Tue, 2 Oct 2018 13:30:57 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 3/5] x86: pgtable: Drop pXd_none() checks from
 pXd_free_pYd_table()
In-Reply-To: <1538478363-16255-4-git-send-email-will.deacon@arm.com>
Message-ID: <alpine.DEB.2.21.1810021326300.32062@nanos.tec.linutronix.de>
References: <1538478363-16255-1-git-send-email-will.deacon@arm.com> <1538478363-16255-4-git-send-email-will.deacon@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, mhocko@suse.com, akpm@linux-foundation.org, sean.j.christopherson@intel.com

On Tue, 2 Oct 2018, Will Deacon wrote:

Subject prefix wants to be 'x86/pgtable:' please

> Now that the core code checks this for us, we don't need to do it in the
> backend.

According to Documentation changelogs want to be written in imperative
mood.

  The core code has a check for pXd_none() already. Remove it in the
  architecture implementation.

Or something like that.

> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>

Other than the nits above:

  Acked-by: Thomas Gleixner <tglx@linutronix.de>
