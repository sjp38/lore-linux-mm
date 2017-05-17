Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 73B6E6B02EE
	for <linux-mm@kvack.org>; Tue, 16 May 2017 23:01:22 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e131so139487209pfh.7
        for <linux-mm@kvack.org>; Tue, 16 May 2017 20:01:22 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id 62si739248plc.52.2017.05.16.20.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 May 2017 20:01:21 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id f27so11671575pfe.0
        for <linux-mm@kvack.org>; Tue, 16 May 2017 20:01:21 -0700 (PDT)
Date: Tue, 16 May 2017 20:01:17 -0700
From: Nick Desaulniers <nick.desaulniers@gmail.com>
Subject: Re: [Patch v2] mm/vmscan: fix unsequenced modification and access
 warning
Message-ID: <20170517030115.2xxx7hhgkklmfwic@lostoracle.net>
References: <20170510071511.GA31466@dhcp22.suse.cz>
 <20170510082734.2055-1-nick.desaulniers@gmail.com>
 <20170510083844.GG31466@dhcp22.suse.cz>
 <20170516082746.GA2481@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170516082746.GA2481@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vbabka@suse.cz, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> I guess it is worth reporting this to clang bugzilla. Could you take
> care of that Nick?

Done: https://bugs.llvm.org//show_bug.cgi?id=33065

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
