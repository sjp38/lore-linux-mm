Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C14C6B02FD
	for <linux-mm@kvack.org>; Thu, 25 May 2017 02:50:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g15so24513489wmc.8
        for <linux-mm@kvack.org>; Wed, 24 May 2017 23:50:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k105si23802263wrc.227.2017.05.24.23.49.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 23:49:59 -0700 (PDT)
Date: Thu, 25 May 2017 08:49:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] refine and rename slub sysfs
Message-ID: <20170525064957.GF12721@dhcp22.suse.cz>
References: <20170517141146.11063-1-richard.weiyang@gmail.com>
 <20170518090636.GA25471@dhcp22.suse.cz>
 <20170523032705.GA4275@WeideMBP.lan>
 <20170523063911.GC12813@dhcp22.suse.cz>
 <20170524095450.GA7706@WeideMBP.lan>
 <20170524120318.GE14733@dhcp22.suse.cz>
 <20170524152124.GB8445@WeideMacBook-Pro.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170524152124.GB8445@WeideMacBook-Pro.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 24-05-17 23:21:24, Wei Yang wrote:
> On Wed, May 24, 2017 at 02:03:18PM +0200, Michal Hocko wrote:
> >On Wed 24-05-17 17:54:50, Wei Yang wrote:
> >> On Tue, May 23, 2017 at 08:39:11AM +0200, Michal Hocko wrote:
> >[...]
> >> >Is this worth risking breakage of the userspace which consume this data
> >> >now? Do you have any user space code which will greatly benefit from the
> >> >new data and which couldn't do the same with the current format/output?
> >> >
> >> >If yes this all should be in the changelog.
> >> 
> >> The answer is no.
> >> 
> >> I have the same concern as yours. So this patch set could be divided into two
> >> parts: 1. add some new entry with current name convention, 2. change the name
> >> convention.
> >
> >Who is going to use those new entries and for what purpose? Why do we
> >want to expose even more details of the slab allocator to the userspace.
> >Is the missing information something fundamental that some user space
> >cannot work without it? Seriously these are essential questions you
> >should have answer for _before_ posting the patch and mention all those
> >reasons in the changelog.
> 
> It is me who wants to get more details of the slub behavior.  
> AFAIK, no one else is expecting this.

My point is that whatever the reason is, it _should_ be described
properly. This is a user visible change and we will have hard time to
change in future once there is userspace depending on it. So ask
yourself, is this so useful that the future maintenance will be still
reasonable? Also doesn't this export too much of the internal
implementation details that would make future development harder?
Also make sure to CC linux-api mailing list for future posts which
involve user API visible changes.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
