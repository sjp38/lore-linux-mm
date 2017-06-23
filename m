Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0D48E6B0279
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 09:26:03 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 77so12759859wrb.11
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 06:26:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 1si4612228wrq.16.2017.06.23.06.26.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Jun 2017 06:26:01 -0700 (PDT)
Date: Fri, 23 Jun 2017 15:25:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170623132558.GC5308@dhcp22.suse.cz>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170623120812.GS5308@dhcp22.suse.cz>
 <66280cc3-6231-8d35-6d9a-113fe2d80409@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <66280cc3-6231-8d35-6d9a-113fe2d80409@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Larry Finger <Larry.Finger@lwfinger.net>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 23-06-17 15:13:45, Vlastimil Babka wrote:
> On 06/23/2017 02:08 PM, Michal Hocko wrote:
> > On Thu 08-06-17 16:48:31, Michal Hocko wrote:
> >> On Wed 07-06-17 13:56:01, David Rientjes wrote:
> >>
> >> I suspect, so cond_resched seems indeed inappropriate on 32b systems.
> > 
> > The code still seems to be in the mmotm tree.
> 
> Even mainline at this point - 338a16ba1549
> 
> > Are there any plans to fix
> > this or drop the patch?
> 
> https://lkml.kernel.org/r/alpine.DEB.2.10.1706191341550.97821@chino.kir.corp.google.com

Ahh, I have missed that. Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
