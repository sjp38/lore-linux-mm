Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 070866B0032
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 10:31:37 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@variantweb.net>;
	Tue, 3 Sep 2013 10:31:37 -0400
Received: from b01cxnp22033.gho.pok.ibm.com (b01cxnp22033.gho.pok.ibm.com [9.57.198.23])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 6DB60C9006D
	for <linux-mm@kvack.org>; Tue,  3 Sep 2013 10:31:32 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by b01cxnp22033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r83EVWsr31129608
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 14:31:32 GMT
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r83EUVsV008361
	for <linux-mm@kvack.org>; Tue, 3 Sep 2013 11:30:31 -0300
Date: Tue, 3 Sep 2013 09:30:29 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] fix typos in Documentation/vm/zswap.txt
Message-ID: <20130903143029.GA5536@variantweb.net>
References: <1378212854-15296-1-git-send-email-mail@eworm.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378212854-15296-1-git-send-email-mail@eworm.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Hesse <mail@eworm.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, Sep 03, 2013 at 02:54:14PM +0200, Christian Hesse wrote:
> ---
>  Documentation/vm/zswap.txt | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Changes look good.  Just do a couple of things:

1) add a short commit msg
2) resend to Andrew Morton with my acked-by

Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>

Thanks for the patch!

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
