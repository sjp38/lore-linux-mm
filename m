Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2CF6B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:12:02 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id a29so16289283qtb.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:12:02 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y6si791251qkg.9.2017.01.18.10.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 10:12:01 -0800 (PST)
Date: Wed, 18 Jan 2017 19:11:57 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
Message-ID: <20170118181157.GI10177@redhat.com>
References: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
 <20170112172132.GM4947@redhat.com>
 <1e1e7589-9713-e6a4-f57c-bfd94eb3e1e9@linux.vnet.ibm.com>
 <20170118162914.GF10177@redhat.com>
 <4ac20fb0-d9d2-e73f-2f17-1f69929756b7@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ac20fb0-d9d2-e73f-2f17-1f69929756b7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, izik.eidus@ravellosystems.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Wed, Jan 18, 2017 at 06:17:09PM +0100, Claudio Imbrenda wrote:
> That's true. As I said above, my previous example was not very well
> thought. The more realistic scenario is that of having the colored zero
> pages of a guest merged.

That's a good point for making a special case that retains the
coloring of those guest pages, agreed.

Retaining the coloring of guest zero pages is however a different
"feature" than what KSM was supposed to run for though, I mean the
guest may run faster with KSM than without because without KSM you
wouldn't know which host physical page is allocated for each guest
zero page. If you wanted top performance then you wouldn't know if to
enable KSM or not.

I wonder if the zero page coloring would be better solved with a
vhost-zeropage dedicated mechanism that would be always enabled
regardless if KSM is enabled or not. KSM is generally a CPU vs memory
tradeoff, and it's in general good idea to enable it.

It's also ok if KSM improves performance of course, definitely not
forbidden in fact it's ideal, but my point is, the rest of KSM might
decrease performance too, so if you need a top-performance setup for
benchmarks or for some special usage, it'd be hard to decide if to
enable KSM or not on those archs requiring page coloring.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
