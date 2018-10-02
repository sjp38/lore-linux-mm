Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D5DC56B0266
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:01:16 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id q29-v6so1344585edd.0
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:01:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g90-v6si190843edd.313.2018.10.02.07.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 07:01:15 -0700 (PDT)
Date: Tue, 2 Oct 2018 16:01:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 0/3] mm: Fix for movable_node boot option
Message-ID: <20181002140111.GW18290@dhcp22.suse.cz>
References: <20180925153532.6206-1-msys.mizuma@gmail.com>
 <alpine.DEB.2.21.1809272241130.8118@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1809272241130.8118@nanos.tec.linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Masayoshi Mizuma <msys.mizuma@gmail.com>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, linux-kernel@vger.kernel.org, x86@kernel.org

On Thu 27-09-18 22:41:36, Thomas Gleixner wrote:
> On Tue, 25 Sep 2018, Masayoshi Mizuma wrote:
> 
> > This patch series are the fix for movable_node boot option
> > issue which was introduced by commit 124049decbb1 ("x86/e820:
> > put !E820_TYPE_RAM regions into memblock.reserved").
> > 
> > First patch, revert the commit. Second and third patch fix the
> > original issue.
> 
> Can the mm folks please comment on this?

I was under impression that Pavel who authored the original change which
got reverted here has reviewed these patches.
-- 
Michal Hocko
SUSE Labs
