Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 044536B000E
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 06:39:53 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id x13-v6so1175831ybl.17
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 03:39:52 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id p82-v6si195324ywp.570.2018.07.03.03.39.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Jul 2018 03:39:51 -0700 (PDT)
Date: Tue, 3 Jul 2018 06:39:48 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [PATCH 1/2] fs: ext4: use BUG_ON if writepage call comes from
 direct reclaim
Message-ID: <20180703103948.GB27426@thunk.org>
References: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530591079-33813-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, adilger.kernel@dilger.ca, darrick.wong@oracle.com, dchinner@redhat.com, akpm@linux-foundation.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 03, 2018 at 12:11:18PM +0800, Yang Shi wrote:
> direct reclaim doesn't write out filesystem page, only kswapd could do
> it. So, if the call comes from direct reclaim, it is definitely a bug.
> 
> And, Mel Gormane also mentioned "Ultimately, this will be a BUG_ON." In
> commit 94054fa3fca1fd78db02cb3d68d5627120f0a1d4 ("xfs: warn if direct
> reclaim tries to writeback pages").
> 
> Although it is for xfs, ext4 has the similar behavior, so elevate
> WARN_ON to BUG_ON.
> 
> And, correct the comment accordingly.
> 
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Andreas Dilger <adilger.kernel@dilger.ca>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

What's the upside of crashing the kernel if the file sytsem can handle it?

       	   	     	      	  	    - Ted
