Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id DF4546B735B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:26:20 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id b6-v6so3782069pls.16
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:26:20 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c9-v6sor552559plo.22.2018.09.05.06.26.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 05 Sep 2018 06:26:19 -0700 (PDT)
Date: Wed, 5 Sep 2018 16:26:13 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: VM_BUG_ON_PGFLAGS with CONFIG_DEBUG_VM_PGFLAGS=n
Message-ID: <20180905132613.gqc3ifkgiybnhc3m@kshutemo-mobl1>
References: <20180905064800.GX14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905064800.GX14951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Wed, Sep 05, 2018 at 08:48:00AM +0200, Michal Hocko wrote:
> Hi Kirill,
> while looking at something unrelated I have stumbled over %subj and I
> simply do not understand how BUILD_BUG_ON_INVALID is supposed to work
> for page flags checks which are dynamic by definition.
> BUILD_BUG_ON_INVALID is noop without any side effects unless __CHECKER__
> is enabled when it evaluates to ((void )(sizeof((__force long )(e)))).

You've read it backwards. BUILD_BUG_ON_INVALID() is not if __CHECKER__ is
enabled.

> How is this supposed to work? Am I just confused or BUILD_BUG_ON_INVALID
> is simply not a good fit here and all you wanted is the no side-effect
> nature of it?

Without CONFIG_DEBUG_VM_PGFLAGS() is basically nop. BUILD_BUG_ON_INVALID()
here is fance version of nop that check that what you've wrote inside
parses fine. That's it.

-- 
 Kirill A. Shutemov
