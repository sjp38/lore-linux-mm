Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1E46D6B004F
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 10:22:26 -0400 (EDT)
Received: by fxm2 with SMTP id 2so621464fxm.4
        for <linux-mm@kvack.org>; Wed, 23 Sep 2009 07:22:32 -0700 (PDT)
Date: Wed, 23 Sep 2009 16:22:25 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Message-ID: <20090923142225.GA2603@bizet.domek.prywatny>
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909180027.37387.rjw@sisk.pl> <20090922233531.GA3198@bizet.domek.prywatny> <200909230151.36678.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200909230151.36678.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Karol Lewandowski <karol.k.lewandowski@gmail.com>, david.graham@intel.com, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 23, 2009 at 01:51:36AM +0200, Rafael J. Wysocki wrote:
> On Wednesday 23 September 2009, Karol Lewandowski wrote:
> > On Fri, Sep 18, 2009 at 12:27:37AM +0200, Rafael J. Wysocki wrote:
> > > Adding linux-mm to the CC list.
> > 
> > I've hit this bug 2 times since my last email.  Is there anything I
> > could do?
> > 
> > Maybe I should revert following commits (chosen somewhat randomly)?
> > 
> > 1. 49255c619fbd482d704289b5eb2795f8e3b7ff2e
> > 
> > 2. dd5d241ea955006122d76af88af87de73fec25b4 - alters changes made by
> > commit above
> > 
> > Any ideas?
> 
> You can try that IMO.

Reverting commits above made situation worse.  Hints?  Obvious
solutions? ;-)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
