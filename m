Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD636B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 02:58:15 -0500 (EST)
Received: by mail-qa0-f46.google.com with SMTP id j7so101737qaq.5
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 23:58:15 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u7si8080913qab.16.2015.01.21.23.58.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jan 2015 23:58:15 -0800 (PST)
Date: Thu, 22 Jan 2015 15:57:42 +0800
From: WANG Chao <chaowang@redhat.com>
Subject: Re: [PATCH] mm, vmacache: Add kconfig VMACACHE_SHIFT
Message-ID: <20150122075742.GA11335@dhcp-129-179.nay.redhat.com>
References: <1421908189-18938-1-git-send-email-chaowang@redhat.com>
 <1421912761.4903.22.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421912761.4903.22.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi, Davidlohr

On 01/21/15 at 11:46pm, Davidlohr Bueso wrote:
> On Thu, 2015-01-22 at 14:29 +0800, WANG Chao wrote:
> > Add a new kconfig option VMACACHE_SHIFT (as a power of 2) to specify the
> > number of slots vma cache has for each thread. Range is chosen 0-4 (1-16
> > slots) to consider both overhead and performance penalty. Default is 2
> > (4 slots) as it originally is, which provides good enough balance.
> > 
> 
> Nack. I don't feel comfortable making scalability features of core code
> configurable.

Out of respect, is this a general rule not making scalability features
of core code configurable?

Thanks
WANG Chao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
