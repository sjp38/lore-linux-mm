Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id D9A3E6B0031
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 13:44:28 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so8813390pab.34
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 10:44:27 -0800 (PST)
Received: from mail-pb0-x22c.google.com (mail-pb0-x22c.google.com [2607:f8b0:400e:c01::22c])
        by mx.google.com with ESMTPS id rx8si25697555pac.163.2014.02.04.10.44.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Feb 2014 10:44:25 -0800 (PST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so8805019pbb.31
        for <linux-mm@kvack.org>; Tue, 04 Feb 2014 10:44:25 -0800 (PST)
Message-ID: <1391539464.10160.1.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Feb 2014 10:44:24 -0800
In-Reply-To: <871tzirdwf.fsf@xmission.com>
References: <87r47jsb2p.fsf@xmission.com>
	 <1391530721.4301.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <871tzirdwf.fsf@xmission.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 2014-02-04 at 09:22 -0800, Eric W. Biederman wrote:

> The two code paths below certainly look good canidates for having
> __GFP_NORETRY added to them.  The same issues I ran into with
> alloc_fdmem are likely to show up there as well.

Yes, this is what I thought : a write into TCP socket should be more
frequent than the alloc_fdmem() case ;)

But then, maybe your workload was only using UDP ?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
