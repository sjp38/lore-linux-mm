Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id AB5C46B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 04:55:21 -0400 (EDT)
Date: Mon, 17 Jun 2013 09:55:18 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [iput] BUG: Bad page state in process rm pfn:0b0ce
Message-ID: <20130617085518.GG1875@suse.de>
References: <20130613102549.GD31394@localhost>
 <20130614091655.GD1875@suse.de>
 <20130615075623.GA2666@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130615075623.GA2666@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Jun 15, 2013 at 03:56:23PM +0800, Fengguang Wu wrote:
> On Fri, Jun 14, 2013 at 10:16:55AM +0100, Mel Gorman wrote:
> > On Thu, Jun 13, 2013 at 06:25:49PM +0800, Fengguang Wu wrote:
> > > Greetings,
> > > 
> > > I got the below dmesg in linux-next and the first bad commit is
> > > 
> > 
> > Thanks Fengguang.
> > 
> > Can you try the following please? I do not see the same issue
> > unfortunately but I am the wrong type of unlucky here.
> 
> Mel, this reliably fixes the problem.
> 
> Tested-by: Fengguang Wu <fengguang.wu@intel.com>
> 

Thanks very much. Patch is winging its way to Andrew now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
