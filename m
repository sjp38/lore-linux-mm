Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 48D3F6B0036
	for <linux-mm@kvack.org>; Tue,  8 Apr 2014 12:58:03 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so1252380pde.25
        for <linux-mm@kvack.org>; Tue, 08 Apr 2014 09:58:02 -0700 (PDT)
Received: from qmta14.emeryville.ca.mail.comcast.net (qmta14.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:212])
        by mx.google.com with ESMTP id xk5si1359720pbc.99.2014.04.08.09.58.02
        for <linux-mm@kvack.org>;
        Tue, 08 Apr 2014 09:58:02 -0700 (PDT)
Date: Tue, 8 Apr 2014 11:57:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: numastats updates
In-Reply-To: <5344288E.3090306@oracle.com>
Message-ID: <alpine.DEB.2.10.1404081153460.12735@nuc>
References: <533D3BC7.8010309@oracle.com> <20140407013932.GU22728@two.firstfloor.org> <alpine.DEB.2.10.1404071044310.9896@nuc> <5344288E.3090306@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-numa@vger.kernel.org, ltp-list <ltp-list@lists.sourceforge.net>, vasily Isaenko <vasily.isaenko@oracle.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-mm@kvack.org

On Tue, 8 Apr 2014, Stanislav Kholmanskikh wrote:

> On a two-node system it prints:
> 1: 294
..

> 20: 294
>
> i.e. everything is ok.
>
> But on an eight-node system:
> 1: 173
> 2: 0
> 3: 0
> 4: 173
> 5: 173


> So in general we can't rely on stat_interval value. Correct?

Owww... This could have something to do with the tick being disabled on
idle without regard for pending vmstat updates. The processor goes to
sleep and never updates the global counters. Once in awhile the processor
wakes up to deal with the statistics.

The idle logic needs to check that all differentials are folded before
going to slee. Frederic: Can we add such a check?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
