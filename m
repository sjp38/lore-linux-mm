Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 23C536B00BE
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 15:55:12 -0400 (EDT)
Date: Mon, 27 Apr 2009 12:52:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Display 0 in meminfo for Committed_AS when value
 underflows
Message-Id: <20090427125208.94730dd8.akpm@linux-foundation.org>
In-Reply-To: <1240848914.29485.52.camel@nimitz>
References: <1240848620-16751-1-git-send-email-ebmunson@us.ibm.com>
	<1240848914.29485.52.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: ebmunson@us.ibm.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Apr 2009 09:15:14 -0700
Dave Hansen <dave@linux.vnet.ibm.com> wrote:

> On Mon, 2009-04-27 at 17:10 +0100, Eric B Munson wrote:
> > Splitting this patch from the chunk that addresses the cause of the underflow
> > because the solution still requires some discussion.
> > 
> > Dave Hansen reported that under certain cirumstances the Committed_AS value
> > can underflow which causes extremely large numbers to be displayed in
> > meminfo.  This patch adds an underflow check to meminfo_proc_show() for the
> > Committed_AS value.  Most fields in /proc/meminfo already have an underflow
> > check, this brings Committed_AS into line.
> 
> Yeah, this is the right fix for now until we can iron out the base
> issues.  Eric, I think this may also be a candidate for -stable.
> 
> Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

I cannot find Eric's original patch anywhere.  Did some demented MTA munch it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
