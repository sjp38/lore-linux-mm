Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 72B446B0035
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:43:03 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id t10so578304eei.35
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 15:43:02 -0800 (PST)
Received: from lxorguk.ukuu.org.uk (lxorguk.ukuu.org.uk. [81.2.110.251])
        by mx.google.com with ESMTPS id p44si3996915eeu.152.2014.02.19.15.43.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Feb 2014 15:43:01 -0800 (PST)
Date: Wed, 19 Feb 2014 23:42:18 +0000
From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [RFC] mm:prototype for the updated swapoff implementation
Message-ID: <20140219234218.51c84c08@alan.etchedpixels.co.uk>
In-Reply-To: <20140219132757.58b61f07bad914b3848275e9@linux-foundation.org>
References: <20140219003522.GA8887@kelleynnn-virtual-machine>
	<20140219132757.58b61f07bad914b3848275e9@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kelley Nielsen <kelleynnn@gmail.com>, riel@surriel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, opw-kernel@googlegroups.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, Hugh Dickins <hughd@google.com>

> Do you have situations in which swapoff is taking an unacceptable
> amount of time?  If so, please update the changelog to provide full
> details on this, with before-and-after timing measurements.

Yes - because now and then (about once a month) with 3.10 or so + and
encrypted swap my box with 16GB RAM gets into a weird 'slow swapping'
state and only swapoff/swapon gets it back to sanity.

In those cases (and in general) swapoff can take half an hour to run.

There is a reproducer for the swap hang at
https://bugzilla.kernel.org/show_bug.cgi?id=62321

The case I see in normal use (gimp of 1200dpi+ A3 images) hits a crawl
not a hang and does recover but only if you swapoff/swapon again

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
