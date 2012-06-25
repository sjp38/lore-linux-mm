Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id A9C6A6B0348
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 10:11:51 -0400 (EDT)
Received: by yenr5 with SMTP id r5so3589895yen.14
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 07:11:50 -0700 (PDT)
Date: Mon, 25 Jun 2012 07:11:45 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 01/10] zcache: fix preemptable memory allocation in
 atomic context
Message-ID: <20120625141145.GA32567@kroah.com>
References: <4FE0392E.3090300@linux.vnet.ibm.com>
 <4FE36D32.3030408@linux.vnet.ibm.com>
 <20120623030052.GA18440@kroah.com>
 <4FE86C1D.2020302@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FE86C1D.2020302@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jun 25, 2012 at 08:48:13AM -0500, Seth Jennings wrote:
> On 06/22/2012 10:00 PM, Greg Kroah-Hartman wrote:
> > On Thu, Jun 21, 2012 at 01:51:30PM -0500, Seth Jennings wrote:
> >> I just noticed you sent this patchset to Andrew, but the
> >> staging tree is maintained by Greg.  You're going to want to
> >> send these patches to him.
> >>
> >> Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > 
> > After this series is redone, right?  As it is, this submission didn't
> > look ok, so I'm hoping a second round is forthcoming...
> 
> Yes. That is the cleanest way since there are dependencies
> among the patches.  You could pull 04-08 and be ok, but you
> might just prefer a repost.

I do prefer a repost, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
