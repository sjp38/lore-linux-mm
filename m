Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 701A16B0033
	for <linux-mm@kvack.org>; Wed, 25 Oct 2017 07:49:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x7so20773537pfa.19
        for <linux-mm@kvack.org>; Wed, 25 Oct 2017 04:49:42 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id z5si1733451pge.203.2017.10.25.04.49.40
        for <linux-mm@kvack.org>;
        Wed, 25 Oct 2017 04:49:41 -0700 (PDT)
Date: Wed, 25 Oct 2017 20:49:38 +0900
From: Byungchul Park <byungchul.park@lge.com>
Subject: Re: [RESEND PATCH 1/3] completion: Add support for initializing
 completion with lockdep_map
Message-ID: <20171025114938.GA3223@X58A-UD3R>
References: <1508319532-24655-1-git-send-email-byungchul.park@lge.com>
 <1508319532-24655-2-git-send-email-byungchul.park@lge.com>
 <1508455438.4542.4.camel@wdc.com>
 <alpine.DEB.2.20.1710200829340.3083@nanos>
 <1508529532.3029.15.camel@wdc.com>
 <CANrsvRNnOp_rgEWG2FGg7qaEQi=yEyhiZkpWSW62w21BvJ9Shg@mail.gmail.com>
 <1508682894.2564.8.camel@wdc.com>
 <20171023020822.GI3310@X58A-UD3R>
 <1508915222.2947.15.camel@wdc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1508915222.2947.15.camel@wdc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "mingo@kernel.org" <mingo@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "peterz@infradead.org" <peterz@infradead.org>, "hch@infradead.org" <hch@infradead.org>, "amir73il@gmail.com" <amir73il@gmail.com>, "linux-xfs@vger.kernel.org" <linux-xfs@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "oleg@redhat.com" <oleg@redhat.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "johannes.berg@intel.com" <johannes.berg@intel.com>, "max.byungchul.park@gmail.com" <max.byungchul.park@gmail.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "idryomov@gmail.com" <idryomov@gmail.com>, "tj@kernel.org" <tj@kernel.org>, "kernel-team@lge.com" <kernel-team@lge.com>, "david@fromorbit.com" <david@fromorbit.com>

On Wed, Oct 25, 2017 at 07:07:06AM +0000, Bart Van Assche wrote:
> > Please, point out logical problems of cross-release than saying it's
> > impossbile according to the paper.
> 
> Isn't that the same? If it's impossible to use lock-graphs for detecting deadlocks
> in programs that use mutexes, semaphores and condition variables without triggering
> false positives that means that every approach that tries to detect deadlocks and
> that is based on lock graphs, including cross-release, must report false positives
> for certain programs.

Right. That's why I'm currently trying to assign lock classes properly
where false positives were reported. You seems to say there is another
cause of false positives. If yes, please let me know what it is. If you
do with an example, it would be more helpful for me to understand you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
