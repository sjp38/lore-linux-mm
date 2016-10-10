Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE046B0038
	for <linux-mm@kvack.org>; Mon, 10 Oct 2016 13:20:52 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id x23so43372554lfi.0
        for <linux-mm@kvack.org>; Mon, 10 Oct 2016 10:20:51 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 81si18129847ljb.37.2016.10.10.10.20.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Oct 2016 10:20:50 -0700 (PDT)
Date: Mon, 10 Oct 2016 13:16:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC 0/4] try to reduce fragmenting fallbacks
Message-ID: <20161010171646.GA6281@cmpxchg.org>
References: <20160928014148.GA21007@cmpxchg.org>
 <20160929210548.26196-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160929210548.26196-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hi Vlastimil,

sorry for the delay, I just got back from traveling.

On Thu, Sep 29, 2016 at 11:05:44PM +0200, Vlastimil Babka wrote:
> Hi Johannes,
> 
> here's something quick to try or ponder about. However, untested since it's too
> late here. Based on mmotm-2016-09-27-16-08 plus this fix [1]
> 
> [1] http://lkml.kernel.org/r/<cadadd38-6456-f58e-504f-cc18ddc47b3f@suse.cz>

Thanks for whipping something up, I'll give these a shot. 4/4 is
something I wondered about too. Let's see how this performs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
