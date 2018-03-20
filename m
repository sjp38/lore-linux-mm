Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 74FBD6B0005
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 13:50:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 1-v6so1561269plv.6
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 10:50:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z19si1649797pfd.397.2018.03.20.10.50.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 10:50:11 -0700 (PDT)
Date: Tue, 20 Mar 2018 10:50:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: Warn on lock_page() from reclaim context.
Message-Id: <20180320105009.2a7055bd3dfefe750d01cd38@linux-foundation.org>
In-Reply-To: <20180320084445.GE23100@dhcp22.suse.cz>
References: <1521295866-9670-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
	<201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
	<20180319150824.24032e2854908b0cc5240d9f@linux-foundation.org>
	<20180320084445.GE23100@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kirill@shutemov.name, linux-mm@kvack.org, kirill.shutemov@linux.intel.com

On Tue, 20 Mar 2018 09:44:45 +0100 Michal Hocko <mhocko@suse.com> wrote:

> > And I wonder if overloading CONFIG_PROVE_LOCKING is appropriate here. 
> > CONFIG_PROVE_LOCKING is a high-level thing under which a whole bunch of
> > different debugging options may exist.
> 
> Yes but it is meant to catch locking issues in general so I think doing
> this check under the same config makes sense.
> 
> > I guess we should add a new config item under PROVE_LOCKING,
> 
> I am not convinced a new config is really worth it. We have way too many
> already and PROVE_LOCKING sounds like a good fit to me.

I few scruffy misc sites have used PROVE_LOCKING in this fashion, but
they really shouldn't have.  It means that if anyone wants to enable,
say, "Locking API boot-time self-tests" then they must enable
PROVE_LOCKING, so they accidentally get this feature as well.
