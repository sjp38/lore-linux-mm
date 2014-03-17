Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 18B5A6B008A
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 06:15:39 -0400 (EDT)
Received: by mail-ig0-f178.google.com with SMTP id uq10so4989706igb.5
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 03:15:38 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id pe7si8043807icc.204.2014.03.17.03.15.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Mar 2014 03:15:38 -0700 (PDT)
Date: Mon, 17 Mar 2014 11:15:27 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: kmemcheck: OS boot failed because NMI handlers access the memory
 tracked by kmemcheck
Message-ID: <20140317101527.GB27965@twins.programming.kicks-ass.net>
References: <5326BE25.9090201@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5326BE25.9090201@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, vegard.nossum@oracle.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Vegard Nossum <vegard.nossum@gmail.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizefan@huawei.com>

On Mon, Mar 17, 2014 at 05:19:33PM +0800, Xishi Qiu wrote:
> Now we don't support page faults in NMI context is that we
> may already be handling an existing fault (or trap) when the NMI hits.
> So that would mess up kmemcheck's working state.

I think it was suggested earlier that kmemcheck could maybe have a stack
of states.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
