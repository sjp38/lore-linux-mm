Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 599646B0005
	for <linux-mm@kvack.org>; Mon, 14 May 2018 12:35:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id n26-v6so6550895pgd.2
        for <linux-mm@kvack.org>; Mon, 14 May 2018 09:35:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w5-v6si10216992pfi.88.2018.05.14.09.35.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 May 2018 09:35:11 -0700 (PDT)
Date: Mon, 14 May 2018 09:19:10 -0700
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH -next 0/2] ipc/shm: shmat() fixes around nil-page
Message-ID: <20180514161910.gbt32tfsocpddaav@linux-n805>
References: <20180503203243.15045-1-dave@stgolabs.net>
 <8addf0c1-26cd-add9-fb9c-292cc3567014@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <8addf0c1-26cd-add9-fb9c-292cc3567014@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, joe.lawrence@redhat.com, gareth.evans@contextis.co.uk, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, ltp@lists.linux.it

On Thu, 10 May 2018, Vlastimil Babka wrote:

>Can you add appropriate Fixes: tags if possible? I guess patch 1 is
>clear, dunno about patch 2...

Right, patch 1 would still benefit from Fixes tag. As to patch 2, the bug
as been there since forever (pre-dates git history). But yeah, as both come
together and are related to a certain extent, the same Fixes could serve both
patches.

Thanks,
Davidlohr
