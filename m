Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 73CD46B011A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2012 10:37:56 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Thu, 4 Oct 2012 10:37:55 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q94EbFQC36569294
	for <linux-mm@kvack.org>; Thu, 4 Oct 2012 10:37:16 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q94Ea3Ux002862
	for <linux-mm@kvack.org>; Thu, 4 Oct 2012 08:36:03 -0600
Message-ID: <506D9ED1.8060903@linux.vnet.ibm.com>
Date: Thu, 04 Oct 2012 09:36:01 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm: add support for zsmalloc and zcache
References: <1346794486-12107-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120921161252.GV11266@suse.de> <20120921180222.GA7220@phenom.dumpdata.com> <505CB9BC.8040905@linux.vnet.ibm.com> <42d62a30-bd6c-4bd7-97d1-bec2f237756b@default> <50609794.8030508@linux.vnet.ibm.com> <b34c65c9-4b25-431d-8b82-cbe911126be9@default> <5064B647.3000906@linux.vnet.ibm.com> <76d1a3f1-efc5-48b5-b485-604a94adcc1d@default> <506B2C4B.3080508@linux.vnet.ibm.com> <771b722f-3036-451a-a416-e6ab5b4a05f7@default>
In-Reply-To: <771b722f-3036-451a-a416-e6ab5b4a05f7@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org, James Bottomley <James.Bottomley@HansenPartnership.com>

On 10/02/2012 01:17 PM, Dan Magenheimer wrote:
> If so, <shake hands> and move forward?  What do you see as next steps?

I'll need to get up to speed on the new codebase before I can answer
this.  I should be able to answer by early next week.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
