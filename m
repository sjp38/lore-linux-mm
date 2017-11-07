Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFFA28026B
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 11:03:31 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id 189so2672875iow.14
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 08:03:31 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0089.hostedemail.com. [216.40.44.89])
        by mx.google.com with ESMTPS id 6si1561601itv.66.2017.11.07.08.03.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 08:03:30 -0800 (PST)
Message-ID: <1510070607.1000.23.camel@perches.com>
Subject: Re: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
From: Joe Perches <joe@perches.com>
Date: Tue, 07 Nov 2017 08:03:27 -0800
In-Reply-To: <20171107154351.ebtitvjyo5v3bt26@dhcp22.suse.cz>
References: 
	<b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
	 <20171107125055.cl5pyp2zwon44x5l@dhcp22.suse.cz>
	 <1510068865.1000.19.camel@perches.com>
	 <20171107154351.ebtitvjyo5v3bt26@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2017-11-07 at 16:43 +0100, Michal Hocko wrote:
> On Tue 07-11-17 07:34:25, Joe Perches wrote:
[]
> > I believe, but have not tested, that using a specific width
> > as an argument to %*pb[l] will constrain the number of
> > spaces before the '(null)' output in any NULL pointer use.
> > 
> > So how about a #define like
> > 
> > /*
> >  * nodemask_pr_args is only used with a "%*pb[l]" format for a nodemask.
> >  * A NULL nodemask uses 6 to emit "(null)" without leading spaces.
> >  */
> > #define nodemask_pr_args(maskp)			\
> > 	(maskp) ? MAX_NUMNODES : 6,		\
> > 	(maskp) ? (maskp)->bits : NULL
> 
> Why not -1 then?

I believe it's the field width and not the precision that
needs to be set.

But if you test it and it works, then that's fine by me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
