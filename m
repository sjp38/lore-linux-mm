Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 67D536B0034
	for <linux-mm@kvack.org>; Wed, 26 Jun 2013 20:21:33 -0400 (EDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 27 Jun 2013 10:11:52 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8B8C13578045
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:21:27 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5R0LHV06619408
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:21:18 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5R0LQIZ005540
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 10:21:26 +1000
Date: Thu, 27 Jun 2013 08:21:24 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] mm/slab: Sharing s_next and s_stop between slab and
 slub
Message-ID: <20130627002124.GA12151@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1372069394-26167-2-git-send-email-liwanp@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1306241421560.25343@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jun 24, 2013 at 02:23:11PM -0700, David Rientjes wrote:
>On Mon, 24 Jun 2013, Wanpeng Li wrote:
>
>> This patch shares s_next and s_stop between slab and slub.
>> 
>
>Just about the entire kernel includes slab.h, so I think you'll need to 
>give these slab-specific names instead of exporting "s_next" and "s_stop" 
>to everybody.

Ok, I will update them in next version, thanks for your review. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
