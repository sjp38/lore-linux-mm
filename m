Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 7076C6B0074
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 16:07:43 -0400 (EDT)
Date: Tue, 4 Sep 2012 15:57:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH v2 0/3] promote zcache from staging
Message-ID: <20120904195711.GC12469@phenom.dumpdata.com>
References: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1346788969-4100-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, Sep 04, 2012 at 03:02:46PM -0500, Seth Jennings wrote:
> zcache is the remaining piece of code required to support in-kernel
> memory compression.  The other two features, cleancache and frontswap,
> have been promoted to mainline in 3.0 and 3.5 respectively.  This
> patchset promotes zcache from the staging tree to mainline.

Could you please post it as a singular path. As if it was out-off-tree?
That way it will be much easier to review it by looking at the full code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
