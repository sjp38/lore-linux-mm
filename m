Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5MHUmRX641886
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 13:30:49 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5MHUmBj325152
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 11:30:48 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5MHUm41000916
	for <linux-mm@kvack.org>; Wed, 22 Jun 2005 11:30:48 -0600
Message-ID: <42B9A041.8000301@austin.ibm.com>
Date: Wed, 22 Jun 2005 12:30:41 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 2.6.12-rc5 2/10] mm: manual page migration-rc3
 -- xfs-migrate-page-rc3.patch
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <20050622163921.25515.62325.69270@tomahawk.engr.sgi.com>
In-Reply-To: <20050622163921.25515.62325.69270@tomahawk.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

> However, the routine "xfs_skip_migrate_page()" is added to
> disallow migration of xfs metadata.

On ppc64 we are aiming to eventually be able to migrate ALL data.  I 
understand we aren't nearly there yet.  I'd like to keep track of what 
we need to do to get there.  What do we need to do to be able to migrate 
xfs metadata?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
