Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8C4566B0034
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 12:29:36 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Mon, 9 Sep 2013 10:29:35 -0600
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 96DB86E80A5
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 12:29:17 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r89GTC2P27590816
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 16:29:12 GMT
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r89GTBbw022010
	for <linux-mm@kvack.org>; Mon, 9 Sep 2013 13:29:12 -0300
Date: Mon, 9 Sep 2013 11:29:09 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 3/4] mm/zswap: avoid unnecessary page scanning
Message-ID: <20130909162909.GB4701@variantweb.net>
References: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000701ceaac0$71c43590$554ca0b0$%yang@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: minchan@kernel.org, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Sep 06, 2013 at 01:16:45PM +0800, Weijie Yang wrote:
> add SetPageReclaim before __swap_writepage so that page can be moved to the
> tail of the inactive list, which can avoid unnecessary page scanning as this
> page was reclaimed by swap subsystem before.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
