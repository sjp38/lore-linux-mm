Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 161676B0254
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 03:54:06 -0400 (EDT)
Received: by lahg1 with SMTP id g1so63007058lah.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:54:05 -0700 (PDT)
Received: from mail-la0-x234.google.com (mail-la0-x234.google.com. [2a00:1450:4010:c03::234])
        by mx.google.com with ESMTPS id y9si10211367lae.127.2015.09.21.00.54.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 00:54:04 -0700 (PDT)
Received: by lahg1 with SMTP id g1so63006838lah.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:54:04 -0700 (PDT)
Date: Mon, 21 Sep 2015 10:54:02 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150921075402.GB3181@uranus>
References: <20150917193152.GJ2000@uranus>
 <20150918085835.597fb036@mschwide>
 <20150918071549.GA2035@uranus>
 <20150918102001.0e0389c7@mschwide>
 <20150918085301.GC2035@uranus>
 <20150918111038.58c3a8de@mschwide>
 <20150918202109.GE2035@uranus>
 <20150921091033.1799ea40@mschwide>
 <20150921073033.GA3181@uranus>
 <20150921094019.6b311a9b@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921094019.6b311a9b@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, Sep 21, 2015 at 09:40:19AM +0200, Martin Schwidefsky wrote:
> > Ah, I see. Could you please note this fact in the patch
> > changelog.
>  
> Sure will do. I'll send a patch set after I got the x86 test sorted out.

Great! Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
