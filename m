Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id BCE076B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 09:38:25 -0400 (EDT)
Received: by wixw10 with SMTP id w10so20839557wix.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 06:38:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si3254579wib.87.2015.03.20.06.38.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Mar 2015 06:38:22 -0700 (PDT)
Date: Fri, 20 Mar 2015 14:38:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID:
 1atdrivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
Message-ID: <20150320133820.GB4821@dhcp22.suse.cz>
References: <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
 <20150317192413.GA7772@phnom.home.cmpxchg.org>
 <1426643634.5570.14.camel@intel.com>
 <201503182045.DEC48482.OtSOQOLVFFHFJM@I-love.SAKURA.ne.jp>
 <1426730222.5570.41.camel@intel.com>
 <201503202234.HIA00180.MQVLSFFtHOOFJO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201503202234.HIA00180.MQVLSFFtHOOFJO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: ying.huang@intel.com, hannes@cmpxchg.org, torvalds@linux-foundation.org, rientjes@google.com, akpm@linux-foundation.org, david@fromorbit.com, linux-kernel@vger.kernel.org, lkp@01.org, linux-mm@kvack.org

On Fri 20-03-15 22:34:21, Tetsuo Handa wrote:
> Huang Ying wrote:
> > > > BTW: the test is run on 32 bit system.
> > > 
> > > That sounds like the cause of your problem. The system might be out of
> > > address space available for the kernel (only 1GB if x86_32). You should
> > > try running tests on 64 bit systems.
> > 
> > We run test on 32 bit and 64 bit systems.  Try to catch problems on both
> > platforms.  I think we still need to support 32 bit systems?
> 
> Yes, testing on both platforms is good. But please read
> http://lwn.net/Articles/627419/ , http://lwn.net/Articles/635354/ and
> http://lwn.net/Articles/636017/ . Then please add __GFP_NORETRY to memory
> allocations in btrfs code if it is appropriate.

I guess you meant __GFP_NOFAIL?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
