Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0D8746B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 03:31:21 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so82610482wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 00:31:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cq10si53323099wjb.266.2017.01.04.00.31.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 00:31:19 -0800 (PST)
Date: Wed, 4 Jan 2017 09:31:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [KERNEL] Re: [KERNEL] Re: Bug 4.9 and memorymanagement
Message-ID: <20170104083117.GC25453@dhcp22.suse.cz>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
 <20161227112844.GG1308@dhcp22.suse.cz>
 <20161230111135.GG13301@dhcp22.suse.cz>
 <20161230165230.th274as75pzjlzkk@ikki.ethgen.ch>
 <20161230172358.GA4266@dhcp22.suse.cz>
 <20170104080639.GB25453@dhcp22.suse.cz>
 <20170104081527.hq5q4ngevcl3c7k6@ikki.ethgen.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170104081527.hq5q4ngevcl3c7k6@ikki.ethgen.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Klaus Ethgen <Klaus+lkml@ethgen.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 04-01-17 09:15:27, Klaus Ethgen wrote:
> Hi Michal,
> 
> Am Mi den  4. Jan 2017 um  9:06 schrieb Michal Hocko:
> 
> > > Just try to run with the patch and do what you do normally. If you do
> > > not see any OOMs in few days it should be sufficient evidence. From your
> > > previous logs it seems you hit the problem quite early after few hours
> > > as far as I remember.
> > 
> > Did you have chance to run with the patch? I would like to post it for
> > inclusion and feedback from you is really useful.
> 
> Yes. It runs since 2017-01-01 and without problems until today.
> 
> I think it looks good but that is just my feeling. I don't know if it is
> to early to say that.
> 
> I also did some heavy git repository actions to big repositories. The
> system is in swap and still no OOMs.

OK, that is a good indication. I will add your Reported-by to the patch
and if you feel comfortable also Tested-by.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
