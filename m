Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A796C6B02C6
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:38:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id d4-v6so978386wrn.15
        for <linux-mm@kvack.org>; Tue, 15 May 2018 13:38:34 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4-v6si1135000edd.111.2018.05.15.13.38.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 13:38:32 -0700 (PDT)
Date: Tue, 15 May 2018 22:38:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Message-ID: <20180515203830.GK12670@dhcp22.suse.cz>
References: <20180510115356.31164-1-pasha.tatashin@oracle.com>
 <20180510123039.GF5325@dhcp22.suse.cz>
 <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
 <20180515091036.GC12670@dhcp22.suse.cz>
 <CAGM2reaQusBA-nmQ5xqH4u-EVxgJCnaHAZs=1AXFOpNWTh7VbQ@mail.gmail.com>
 <20180515125541.GH12670@dhcp22.suse.cz>
 <CAGM2reYGFjG38FW0nEf1gwRMfDyVQ7QCGZ83VewxXgedeT=Zsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reYGFjG38FW0nEf1gwRMfDyVQ7QCGZ83VewxXgedeT=Zsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

On Tue 15-05-18 11:59:25, Pavel Tatashin wrote:
> > This will always be a maze as the early boot tends to be. Sad but true.
> > That is why I am not really convinced we should use a large hammer and
> > disallow deferred page initialization just because UP implementation of
> > pcp does something too early. We should instead rule that one odd case.
> > Your patch simply doesn't rule a large class of potential issues. It
> > just rules out a potentially useful feature for an odd case. See my
> > point?
> 
> Hi Michal,
> 
> OK, I will send an updated patch with disabling deferred pages only whe
> NEED_PER_CPU_KM. Hopefully, we won't see similar issues in other places.

If we do we will probably need to think more about a more systematic
solution.
-- 
Michal Hocko
SUSE Labs
