Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id ADCF96B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 06:11:39 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id l2so40707044wml.5
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 03:11:39 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qa4si61831230wjc.238.2016.12.30.03.11.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 03:11:38 -0800 (PST)
Date: Fri, 30 Dec 2016 12:11:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Bug 4.9 and memorymanagement
Message-ID: <20161230111135.GG13301@dhcp22.suse.cz>
References: <20161225205251.nny6k5wol2s4ufq7@ikki.ethgen.ch>
 <20161226110053.GA16042@dhcp22.suse.cz>
 <20161227112844.GG1308@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161227112844.GG1308@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Klaus Ethgen <Klaus+lkml@ethgen.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 27-12-16 12:28:44, Michal Hocko wrote:
> On Mon 26-12-16 12:00:53, Michal Hocko wrote:
> > [CCing linux-mm]
> > 
> > On Sun 25-12-16 21:52:52, Klaus Ethgen wrote:
> > > Hello,
> > > 
> > > The last days I compiled version 4.9 for my i386 laptop. (Lenovo x61s)
> > 
> > Do you have memory cgroups enabled in runtime (aka does the same happen
> > with cgroup_disable=memory)?
> 
> If this turns out to be memory cgroup related then the patch from
> http://lkml.kernel.org/r/20161226124839.GB20715@dhcp22.suse.cz might
> help.

Did you get chance to test the above patch? I would like to send it for
merging and having it tested on another system would be really helpeful
and much appreciated.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
