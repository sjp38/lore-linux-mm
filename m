Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 92DBB8E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 16:41:40 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id o17so3971085wrx.5
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 13:41:40 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id f200-v6si81392wme.36.2018.09.27.13.41.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 27 Sep 2018 13:41:39 -0700 (PDT)
Date: Thu, 27 Sep 2018 22:41:36 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 0/3] mm: Fix for movable_node boot option
In-Reply-To: <20180925153532.6206-1-msys.mizuma@gmail.com>
Message-ID: <alpine.DEB.2.21.1809272241130.8118@nanos.tec.linutronix.de>
References: <20180925153532.6206-1-msys.mizuma@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, x86@kernel.org

On Tue, 25 Sep 2018, Masayoshi Mizuma wrote:

> This patch series are the fix for movable_node boot option
> issue which was introduced by commit 124049decbb1 ("x86/e820:
> put !E820_TYPE_RAM regions into memblock.reserved").
> 
> First patch, revert the commit. Second and third patch fix the
> original issue.

Can the mm folks please comment on this?

Thanks,

	tglx
