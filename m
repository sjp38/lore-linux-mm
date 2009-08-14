Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A5A26B005A
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 19:25:13 -0400 (EDT)
Date: Fri, 14 Aug 2009 16:19:45 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 4/4] hugetlb: add per node hstate attributes
Message-ID: <20090814231945.GA11364@suse.de>
References: <20090729181139.23716.85986.sendpatchset@localhost.localdomain>
 <20090729181205.23716.25002.sendpatchset@localhost.localdomain>
 <9ec263480907301239i4f6a6973m494f4b44770660dc@mail.gmail.com>
 <20090731103632.GB28766@csn.ul.ie>
 <1249067452.4674.235.camel@useless.americas.hpqcorp.net>
 <alpine.DEB.2.00.0908141532510.23204@chino.kir.corp.google.com>
 <20090814160830.e301d68a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090814160830.e301d68a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Lee.Schermerhorn@hp.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-numa@vger.kernel.org, nacc@us.ibm.com, andi@firstfloor.org, agl@us.ibm.com, apw@canonical.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, Aug 14, 2009 at 04:08:30PM -0700, Andrew Morton wrote:
> On Fri, 14 Aug 2009 15:38:43 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Andrew, Lee, what's the status of this patchset?
> 
> All forgotten about as far as I'm concerned.  It was v1, it had "rfc"
> in there and had an "Ick, no, please don't do that" from Greg.  I
> assume Greg's OK with the fixed-up version.

If the fixed up version does not touch the kobject core in any manner,
then yes, I have no objection.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
