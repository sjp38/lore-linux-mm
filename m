Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6C58D0039
	for <linux-mm@kvack.org>; Tue, 15 Feb 2011 13:19:48 -0500 (EST)
Date: Tue, 15 Feb 2011 13:18:37 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH V2 2/3] drivers/staging: zcache: host services and PAM
 services
Message-ID: <20110215181837.GA26885@dumpdata.com>
References: <20110207032608.GA27453@ca-server1.us.oracle.com>
 <20110215165353.GA6118@dumpdata.com>
 <20110215172548.GD18437@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110215172548.GD18437@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@suse.de>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, chris.mason@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, matthew@wil.cx, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, kurt.hackel@oracle.com, npiggin@kernel.dk, riel@redhat.com, mel@csn.ul.ie, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, sfr@canb.auug.org.au, wfg@mail.ustc.edu.cn, tytso@mit.edu, viro@ZenIV.linux.org.uk, hughd@google.com, hannes@cmpxchg.org

On Tue, Feb 15, 2011 at 09:25:48AM -0800, Greg KH wrote:
> On Tue, Feb 15, 2011 at 11:53:53AM -0500, Konrad Rzeszutek Wilk wrote:
> > On Sun, Feb 06, 2011 at 07:26:08PM -0800, Dan Magenheimer wrote:
> > > [PATCH V2 2/3] drivers/staging: zcache: host services and PAM services
> > 
> > Hey Dan,
> > 
> > I did a simple review of just reading the code and trying to grok it.
> > 
> > Greg,
> > 
> > How does the review work in staging tree? Would you just take
> > new patches from Dan based on my review and he should stick
> > 'Reviewed-by: Konrad...' or .. ?
> 
> I would, if I hadn't already committed these patches, so it'e a bit too
> late for adding that, sorry.

That is OK. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
