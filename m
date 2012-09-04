Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id B71646B007D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:11:36 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 4 Sep 2012 16:11:35 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 1BC7D6E8046
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:11:32 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q84KBVvk117860
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 16:11:31 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q84KBV2j008355
	for <linux-mm@kvack.org>; Tue, 4 Sep 2012 17:11:31 -0300
Message-ID: <5046606B.7000705@linux.vnet.ibm.com>
Date: Tue, 04 Sep 2012 15:11:23 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] promote zcache from staging
References: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com> <20120904195711.GC12469@phenom.dumpdata.com>
In-Reply-To: <20120904195711.GC12469@phenom.dumpdata.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On 09/04/2012 02:57 PM, Konrad Rzeszutek Wilk wrote:
> On Tue, Sep 04, 2012 at 03:02:46PM -0500, Seth Jennings wrote:
>> zcache is the remaining piece of code required to support in-kernel
>> memory compression.  The other two features, cleancache and frontswap,
>> have been promoted to mainline in 3.0 and 3.5 respectively.  This
>> patchset promotes zcache from the staging tree to mainline.
> 
> Could you please post it as a singular path. As if it was out-off-tree?
> That way it will be much easier to review it by looking at the full code.

Ah yes, my bad. Scratch v2. Nothing to see here.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
