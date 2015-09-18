Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id AA8516B0038
	for <linux-mm@kvack.org>; Fri, 18 Sep 2015 03:15:53 -0400 (EDT)
Received: by lamp12 with SMTP id p12so24645795lam.0
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 00:15:53 -0700 (PDT)
Received: from mail-la0-x229.google.com (mail-la0-x229.google.com. [2a00:1450:4010:c03::229])
        by mx.google.com with ESMTPS id 6si4996592lav.58.2015.09.18.00.15.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Sep 2015 00:15:52 -0700 (PDT)
Received: by lahg1 with SMTP id g1so25444626lah.1
        for <linux-mm@kvack.org>; Fri, 18 Sep 2015 00:15:52 -0700 (PDT)
Date: Fri, 18 Sep 2015 10:15:50 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm/swapfile: fix swapoff vs. software dirty bits
Message-ID: <20150918071549.GA2035@uranus>
References: <1442480339-26308-1-git-send-email-schwidefsky@de.ibm.com>
 <1442480339-26308-2-git-send-email-schwidefsky@de.ibm.com>
 <20150917193152.GJ2000@uranus>
 <20150918085835.597fb036@mschwide>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150918085835.597fb036@mschwide>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Fri, Sep 18, 2015 at 08:58:35AM +0200, Martin Schwidefsky wrote:
> > 
> > Martin, could you please elaborate? Seems I'm missing
> > something obvious.
>  
> It is me who missed something.. thanks for the explanation.

Sure thing! Ping me if any.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
