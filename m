Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id A8FE66B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 18:35:50 -0500 (EST)
Received: by widex7 with SMTP id ex7so32459199wid.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 15:35:50 -0800 (PST)
Received: from mail-wg0-x236.google.com (mail-wg0-x236.google.com. [2a00:1450:400c:c00::236])
        by mx.google.com with ESMTPS id eq4si9484184wjd.112.2015.03.04.15.35.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 15:35:49 -0800 (PST)
Received: by wggx13 with SMTP id x13so9778032wgg.4
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 15:35:48 -0800 (PST)
Date: Thu, 5 Mar 2015 00:35:45 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [regression v4.0-rc1] mm: IPIs from TLB flushes causing
 significant performance degradation.
Message-ID: <20150304233544.GA24733@gmail.com>
References: <20150303014733.GL18360@dastard>
 <CA+55aFw+7V9DfxBA2_DhMNrEQOkvdwjFFga5Y67-a6yVeAz+NQ@mail.gmail.com>
 <CA+55aFw+fb=Fh4M2wA4dVskgqN7PhZRGZS6JTMx4Rb1Qn++oaA@mail.gmail.com>
 <20150303052004.GM18360@dastard>
 <CA+55aFyczb5asoTwhzaJr1JdRi1epg1A6cFJgnzMMZj6U0gFWA@mail.gmail.com>
 <20150303113437.GR4251@dastard>
 <20150303134346.GO3087@suse.de>
 <20150303213353.GS4251@dastard>
 <20150304200046.GP3087@suse.de>
 <20150304230045.GZ18360@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150304230045.GZ18360@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Matt B <jackdachef@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs@oss.sgi.com


* Dave Chinner <david@fromorbit.com> wrote:

> > After going through the series again, I did not spot why there is 
> > a difference. It's functionally similar and I would hate the 
> > theory that this is somehow hardware related due to the use of 
> > bits it takes action on.
> 
> I doubt it's hardware related - I'm testing inside a VM, [...]

That might be significant, I doubt Mel considered KVM's interpretation 
of pte details?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
