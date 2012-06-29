Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id CFB396B005A
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 07:19:37 -0400 (EDT)
Date: Fri, 29 Jun 2012 12:19:32 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: MMTests 0.04
Message-ID: <20120629111932.GA14154@suse.de>
References: <20120620113252.GE4011@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120620113252.GE4011@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Wed, Jun 20, 2012 at 12:32:52PM +0100, Mel Gorman wrote:
> MMTests 0.04 is a configurable test suite that runs a number of common
> workloads of interest to MM developers. Apparently I never sent a release
> note for 0.03 so here is the changelog for both
> 

Using MMTests 0.04 I ran a number of tests between 2.6.32 and 3.4 on three
test machines. None of them are particularly powerful but the results are
still useful because it's worth knowing how we are doing for some ordinary
cases over time.

There were 34 test configurations in all taking between 3-5 days to run all
the tests for a single kernel. I expect that not all the results will be
useful when I look closer but that can be improved. I have not looked at
all the results yet and will only talk about the ones I have had a chance
to read.

I know the presentation is ugly but it was not a high priority to make
them very pretty. The analysis is also superficial as it's time consuming
to do a full analysis for any of these tests. In general the stats need
improving but this is also something that can be improved over time once
the raw data can be collected. Right now I tend to look closer at the
data when I am trying to narrow a problem down to a specific area or when
a regression might have been introduced.  When this happens I can usually
apply what stats I need manually or rerun the specific test with additional
monitoring which is less than ideal for automation.

Due to the superficial nature I suggest you take these summaries with a
grain of salt and draw your own conclusions.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
