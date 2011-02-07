Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D7E238D0039
	for <linux-mm@kvack.org>; Sun,  6 Feb 2011 20:43:45 -0500 (EST)
Date: Sun, 6 Feb 2011 17:42:05 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 3/4]Define memory_block_size_bytes for powerpc/pseries
Message-ID: <20110207014205.GA16217@kroah.com>
References: <4D386498.9080201@austin.ibm.com>
 <4D3866A0.6010803@austin.ibm.com>
 <1297035563.14982.15.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1297035563.14982.15.camel@pasglop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nathan Fontenot <nfont@austin.ibm.com>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Robin Holt <holt@sgi.com>

On Mon, Feb 07, 2011 at 10:39:23AM +1100, Benjamin Herrenschmidt wrote:
> On Thu, 2011-01-20 at 10:45 -0600, Nathan Fontenot wrote:
> > Define a version of memory_block_size_bytes() for powerpc/pseries such that
> > a memory block spans an entire lmb.
> > 
> > Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>
> > Reviewed-by: Robin Holt <holt@sgi.com>
> 
> Hi Nathan !
> 
> Is somebody from -mm picking the rest of the series ? This patch as well
> or shall I wait for the first two to go in and then pick that one in
> -powerpc ?

I took all of these in my tree already, is that ok?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
