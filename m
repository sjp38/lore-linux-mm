Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4CA96B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:28:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v14so12238933wmd.3
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 02:28:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si9177717wmf.264.2018.01.30.02.28.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 02:28:57 -0800 (PST)
Date: Tue, 30 Jan 2018 11:28:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] Per file OOM badness
Message-ID: <20180130102855.GY21609@dhcp22.suse.cz>
References: <20180118170006.GG6584@dhcp22.suse.cz>
 <20180123152659.GA21817@castle.DHCP.thefacebook.com>
 <20180123153631.GR1526@dhcp22.suse.cz>
 <ccac4870-ced3-f169-17df-2ab5da468bf0@daenzer.net>
 <20180124092847.GI1526@dhcp22.suse.cz>
 <583f328e-ff46-c6a4-8548-064259995766@daenzer.net>
 <20180124110141.GA28465@dhcp22.suse.cz>
 <36b49523-792d-45f9-8617-32b6d9d77418@daenzer.net>
 <20180124115059.GC28465@dhcp22.suse.cz>
 <60e18da8-4d6e-dec9-7aef-ff003605d513@daenzer.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <60e18da8-4d6e-dec9-7aef-ff003605d513@daenzer.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel =?iso-8859-1?Q?D=E4nzer?= <michel@daenzer.net>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, Christian.Koenig@amd.com, linux-mm@kvack.org, amd-gfx@lists.freedesktop.org, Roman Gushchin <guro@fb.com>

On Tue 30-01-18 10:29:10, Michel Danzer wrote:
> On 2018-01-24 12:50 PM, Michal Hocko wrote:
> > On Wed 24-01-18 12:23:10, Michel Danzer wrote:
> >> On 2018-01-24 12:01 PM, Michal Hocko wrote:
> >>> On Wed 24-01-18 11:27:15, Michel Danzer wrote:
> > [...]
> >>>> 2. If the OOM killer kills a process which is sharing BOs with another
> >>>> process, this should result in the other process dropping its references
> >>>> to the BOs as well, at which point the memory is released.
> >>>
> >>> OK. How exactly are those BOs mapped to the userspace?
> >>
> >> I'm not sure what you're asking. Userspace mostly uses a GEM handle to
> >> refer to a BO. There can also be userspace CPU mappings of the BO's
> >> memory, but userspace doesn't need CPU mappings for all BOs and only
> >> creates them as needed.
> > 
> > OK, I guess you have to bear with me some more. This whole stack is a
> > complete uknonwn. I am mostly after finding a boundary where you can
> > charge the allocated memory to the process so that the oom killer can
> > consider it. Is there anything like that? Except for the proposed file
> > handle hack?
> 
> How about the other way around: what APIs can we use to charge /
> "uncharge" memory to a process? If we have those, we can experiment with
> different places to call them.

add_mm_counter() and I would add a new counter e.g. MM_KERNEL_PAGES.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
