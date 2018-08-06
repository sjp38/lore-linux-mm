Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id D697A6B000A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 11:37:16 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id x26-v6so10899398qtb.2
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 08:37:16 -0700 (PDT)
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id p63-v6si6220212qva.148.2018.08.06.08.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 06 Aug 2018 08:37:15 -0700 (PDT)
Date: Mon, 6 Aug 2018 15:37:14 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: Caching/buffers become useless after some time
In-Reply-To: <20180806120042.GL19540@dhcp22.suse.cz>
Message-ID: <010001650fe29e66-359ffa28-9290-4e83-a7e2-b6d1d8d2ee1d-000000@email.amazonses.com>
References: <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com> <20180716164500.GZ17280@dhcp22.suse.cz> <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com> <c33fba55-3e86-d40f-efe0-0fc908f303bd@suse.cz>
 <20180730144048.GW24267@dhcp22.suse.cz> <CADF2uSr=mjVih1TB397bq1H7u3rPvo0HPqhUiG21AWu+WXFC5g@mail.gmail.com> <1f862d41-1e9f-5324-fb90-b43f598c3955@suse.cz> <CADF2uSrhKG=ntFWe96YyDWF8DFGyy4Jo4YFJFs=60CBXY52nfg@mail.gmail.com> <30f7ec9a-e090-06f1-1851-b18b3214f5e3@suse.cz>
 <CADF2uSocjT5Oz=1Wohahjf5-58YpT2Jm2vTQKuqA=8ywBFwCaQ@mail.gmail.com> <20180806120042.GL19540@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Marinko Catovic <marinko.catovic@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Mon, 6 Aug 2018, Michal Hocko wrote:

> Because a lot of FS metadata is fragmenting the memory and a large
> number of high order allocations which want to be served reclaim a lot
> of memory to achieve their gol. Considering a large part of memory is
> fragmented by unmovable objects there is no other way than to use
> reclaim to release that memory.

Well it looks like the fragmentation issue gets worse. Is that enough to
consider merging the slab defrag patchset and get some work done on inodes
and dentries to make them movable (or use targetd reclaim)?
