Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C115E6B7372
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 09:46:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id g15-v6so2572343edm.11
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 06:46:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m45-v6si2166130edc.143.2018.09.05.06.46.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 06:46:09 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:46:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: VM_BUG_ON_PGFLAGS with CONFIG_DEBUG_VM_PGFLAGS=n
Message-ID: <20180905134607.GF14951@dhcp22.suse.cz>
References: <20180905064800.GX14951@dhcp22.suse.cz>
 <20180905132613.gqc3ifkgiybnhc3m@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905132613.gqc3ifkgiybnhc3m@kshutemo-mobl1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org

On Wed 05-09-18 16:26:13, Kirill A. Shutemov wrote:
> On Wed, Sep 05, 2018 at 08:48:00AM +0200, Michal Hocko wrote:
> > Hi Kirill,
> > while looking at something unrelated I have stumbled over %subj and I
> > simply do not understand how BUILD_BUG_ON_INVALID is supposed to work
> > for page flags checks which are dynamic by definition.
> > BUILD_BUG_ON_INVALID is noop without any side effects unless __CHECKER__
> > is enabled when it evaluates to ((void )(sizeof((__force long )(e)))).
> 
> You've read it backwards. BUILD_BUG_ON_INVALID() is not if __CHECKER__ is
> enabled.

Well, that is what I meant I just reworded the text and kept the
negation...

> > How is this supposed to work? Am I just confused or BUILD_BUG_ON_INVALID
> > is simply not a good fit here and all you wanted is the no side-effect
> > nature of it?
> 
> Without CONFIG_DEBUG_VM_PGFLAGS() is basically nop. BUILD_BUG_ON_INVALID()
> here is fance version of nop that check that what you've wrote inside
> parses fine. That's it.

OK, I see it. I somehow implied that this is similar to BUILD_BUG_ON. If
this is about pure expression correctness then it finally makes some
sense to me.

Thanks!
-- 
Michal Hocko
SUSE Labs
