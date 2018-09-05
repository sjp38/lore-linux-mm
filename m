Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10BF66B71C7
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 02:48:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c16-v6so2173956edc.21
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 23:48:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z53-v6si1167658edc.320.2018.09.04.23.48.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 23:48:02 -0700 (PDT)
Date: Wed, 5 Sep 2018 08:48:00 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: VM_BUG_ON_PGFLAGS with CONFIG_DEBUG_VM_PGFLAGS=n
Message-ID: <20180905064800.GX14951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org

Hi Kirill,
while looking at something unrelated I have stumbled over %subj and I
simply do not understand how BUILD_BUG_ON_INVALID is supposed to work
for page flags checks which are dynamic by definition.
BUILD_BUG_ON_INVALID is noop without any side effects unless __CHECKER__
is enabled when it evaluates to ((void )(sizeof((__force long )(e)))).
How is this supposed to work? Am I just confused or BUILD_BUG_ON_INVALID
is simply not a good fit here and all you wanted is the no side-effect
nature of it?

Thanks!
-- 
Michal Hocko
SUSE Labs
