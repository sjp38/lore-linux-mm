Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A07416B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 05:33:24 -0400 (EDT)
Date: Mon, 24 Sep 2012 12:33:12 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: hot-added cpu is not asiggned to the correct node
Message-ID: <20120924093312.GC28937@mwanda>
References: <50501E97.2020200@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50501E97.2020200@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 12, 2012 at 02:33:11PM +0900, Yasuaki Ishimatsu wrote:
> When I hot-added CPUs and memories simultaneously using container driver,
> all the hot-added CPUs were mistakenly assigned to node0.
> 

Is this something which used to work correctly?  If so which was the
most recent working kernel?

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
