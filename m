Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id D80826B0006
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 14:16:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i24-v6so4503407edq.16
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 11:16:40 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h29-v6si960390edb.301.2018.08.06.11.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 11:16:39 -0700 (PDT)
Date: Mon, 6 Aug 2018 20:16:38 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180806181638.GE10003@dhcp22.suse.cz>
References: <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
 <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
 <20180730144048.GW24267@dhcp22.suse.cz>
 <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com>
 <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz>
 <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com>
 <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
 <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com>
 <20180806120042.GL19540@dhcp22.suse.cz>
 <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Mon 06-08-18 15:37:14, Cristopher Lameter wrote:
> On Mon, 6 Aug 2018, Michal Hocko wrote:
> 
> > Because a lot of FS metadata is fragmenting the memory and a large
> > number of high order allocations which want to be served reclaim a lot
> > of memory to achieve their gol. Considering a large part of memory is
> > fragmented by unmovable objects there is no other way than to use
> > reclaim to release that memory.
> 
> Well it looks like the fragmentation issue gets worse. Is that enough to
> consider merging the slab defrag patchset and get some work done on inodes
> and dentries to make them movable (or use targetd reclaim)?

Is there anything to test?
-- 
Michal Hocko
SUSE Labs
