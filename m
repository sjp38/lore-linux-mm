Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ED12B6B004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2009 14:31:08 -0400 (EDT)
Received: by fxm2 with SMTP id 2so5313603fxm.4
        for <linux-mm@kvack.org>; Wed, 30 Sep 2009 11:48:17 -0700 (PDT)
Date: Wed, 30 Sep 2009 20:48:12 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Message-ID: <20090930184812.GA2484@bizet.domek.prywatny>
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909170118.53965.rjw@sisk.pl> <4AB29F4A.3030102@intel.com> <200909180027.37387.rjw@sisk.pl> <20090922233531.GA3198@bizet.domek.prywatny> <20090929135810.GB14911@csn.ul.ie> <20090930153730.GA2120@bizet.domek.prywatny> <20090930155543.GC17906@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090930155543.GC17906@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, david.graham@intel.com, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 30, 2009 at 04:55:43PM +0100, Mel Gorman wrote:
> On Wed, Sep 30, 2009 at 05:37:30PM +0200, Karol Lewandowski wrote:
> > I've started with bc75d33f0 (one commit before d239171e4 in Linus'
> > tree) but then my system fails to resume.
> > 
> 
> Does the bug require a suspend/resume or would something like
> 
> rmmod e100
> updatedb
> modprobe e100
> 
> reproduce the problem?

Yes, it does reproduce the problem.  Thanks a lot for that.

I'll try to bisect it as my free time permits (which may take a while,
unfortunately).

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
