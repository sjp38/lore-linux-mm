Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 260BD6B0044
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 14:03:10 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 2 Oct 2012 14:03:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q92I349I145216
	for <linux-mm@kvack.org>; Tue, 2 Oct 2012 14:03:04 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q92I2sto018450
	for <linux-mm@kvack.org>; Tue, 2 Oct 2012 15:02:54 -0300
Message-ID: <506B2C4B.3080508@linux.vnet.ibm.com>
Date: Tue, 02 Oct 2012 13:02:51 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com> <505CB9BC.8040905@linux.vnet.ibm.com> <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default> <50609794.8030508@linux.vnet.ibm.com> <b34c65c9-4b25-431d-8b82-cbe911126be9@default> <5064B647.3000906@linux.vnet.ibm.com> <76d1a3f1-efc5-48b5-b485-604a94adcc1d@default>
In-Reply-To: <76d1a3f1-efc5-48b5-b485-604a94adcc1d@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

On 09/27/2012 05:07 PM, Dan Magenheimer wrote:
> Of course, I'm of the opinion that neither zcache1 nor
> zcache2 would be likely to be promoted for at least another
> cycle or two, so if you go with zcache2+zsmalloc as the compromise
> and it still takes six months for promotion, I hope you don't
> blame that on the "rewrite". ;-)
> 
> Anyway, looking forward (hopefully) to working with you on
> a good compromise.  It would be nice to get back to coding
> and working together on a single path forward for zcache
> as there is a lot of work to do!

We want to see zcache moving forward so that it can get out of staging
and into the hands of end users.  From the direction the discussion
has taken, replacing zcache with the new code appears to be the right
compromise for the situation.  Moving to the new zcache code resets
the clock so I would like to know that we're all on the same track...

1- Promotion must be the top priority, focus needs to be on making the
code production ready rather than adding more features.

2- The code is in the community and development must be done in
public, no further large private rewrites.

3- Benchmarks need to be agreed on, Mel has suggested some of the
MMTests. We need a way to talk about performance so we can make
comparisions, avoid regressions, and talk about promotion criteria.
They should be something any developer can run.

4- Let's investigate breaking ramster out of zcache so that zcache
remains a separately testable building block; Konrad was looking at
this I believe.  RAMSTer adds another functional mode for zcache and
adds to the difficulty of validating patches.  Not every developer
has a cluster of machines to validate RAMSter.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
