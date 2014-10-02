Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6F16B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 11:22:01 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id uq10so932601igb.2
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 08:22:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s8si11056214icx.26.2014.10.02.08.21.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 08:21:57 -0700 (PDT)
Date: Thu, 2 Oct 2014 11:13:02 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 0/5] mm: poison critical mm/ structs
Message-ID: <20141002151302.GA15348@redhat.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
 <20141001140725.fd7f1d0cf933fbc2aa9fc1b1@linux-foundation.org>
 <542C749B.1040103@oracle.com>
 <alpine.LSU.2.11.1410020154500.6444@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1410020154500.6444@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de

On Thu, Oct 02, 2014 at 02:23:08AM -0700, Hugh Dickins wrote:

 > I think these patches are fine for investigating whatever is the
 > problem currently afflicting you and mm under trinity; but we all
 > have our temporary debugging patches, I don't think all deserve
 > preservation in everyone else's kernel, that amounts to far more
 > clutter than any are worth.

One problem with keeping things like this in -mm (or other non-Linus tree)
is that they bit-rot quickly, and become a pain to apply, especially if
they are perpetually on top of other changes in -mm.

I looked at trying these patches on Linus' tree when Sasha posted them,
but lost motivation when I realized they needed other bits of -mm too.

It may be that after Andrews 3.18+ mega-merge things would be simpler,
but I have a feeling it wouldn't be long before the situation would
arise again.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
