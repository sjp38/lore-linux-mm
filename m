Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 228C7440874
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 16:16:25 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id g53so27538930qtc.6
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 13:16:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k89si6073132qtd.298.2017.07.13.13.16.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 13:16:24 -0700 (PDT)
Date: Thu, 13 Jul 2017 16:16:20 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM 12/15] mm/migrate: new memory migration helper for use with
 device memory v4
Message-ID: <20170713201620.GB1979@redhat.com>
References: <20170522165206.6284-1-jglisse@redhat.com>
 <20170522165206.6284-13-jglisse@redhat.com>
 <fa402b70fa9d418ebf58a26a454abd06@HQMAIL103.nvidia.com>
 <5f476e8c-8256-13a8-2228-a2b9e5650586@nvidia.com>
 <20170701005749.GA7232@redhat.com>
 <ff6cb2b9-b930-afad-1a1f-1c437eced3cf@nvidia.com>
 <20170711182922.GC5347@redhat.com>
 <7a4478cb-7eb6-2546-e707-1b0f18e3acd4@nvidia.com>
 <20170711184919.GD5347@redhat.com>
 <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84d83148-41a3-d0e8-be80-56187a8e8ccc@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>

On Tue, Jul 11, 2017 at 12:35:03PM -0700, Evgeny Baskakov wrote:
> On 7/11/17 11:49 AM, Jerome Glisse wrote:
> 
> > 
> > What are the symptoms ? The program just stop making any progress and you
> > trigger a sysrequest to dump current states of each threads ? In this
> > log i don't see migration_entry_wait() anymore but it seems to be waiting
> > on page lock so there might be 2 issues here.
> > 
> > Jerome
> 
> That is correct, the program is not making any progress.
> 
> The stack traces in the kernel log are produced by a "sysrq w" (blocked
> tasks) command.
> 

I updated hmm-next with a patch that might fix some other issues but i am
still trying to get this dead lock you are seing. Does it happens quickly
with the test program ?

I can't see how it dead lock on the page lock bit. Going over and over all
code path we always unlock page once we are done or when we back off from
migration. So far i haven't been able to reproduce thought i haven't had
much time to test as other thing kept me busy. I should be back looking into
that tomorrow.

https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-next

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
