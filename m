From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 1/5] mm/slab: Fix drain freelist excessively
Date: Sun, 7 Jul 2013 17:24:48 +0800
Message-ID: <23566.9179972776$1373189116@news.gmane.org>
References: <1372898006-6308-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <0000013faf0d3958-00e5e945-25d8-43c1-ac6e-3d3ad69b2718-000000@email.amazonses.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UvlDQ-0004TR-4I
	for glkm-linux-mm-2@m.gmane.org; Sun, 07 Jul 2013 11:25:08 +0200
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CC8B76B0033
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 05:25:05 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 7 Jul 2013 14:50:01 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B2EDD1258051
	for <linux-mm@kvack.org>; Sun,  7 Jul 2013 14:54:03 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r679PPEF20840536
	for <linux-mm@kvack.org>; Sun, 7 Jul 2013 14:55:25 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r679OoG9027547
	for <linux-mm@kvack.org>; Sun, 7 Jul 2013 19:24:51 +1000
Content-Disposition: inline
In-Reply-To: <0000013faf0d3958-00e5e945-25d8-43c1-ac6e-3d3ad69b2718-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 05, 2013 at 01:37:28PM +0000, Christoph Lameter wrote:
>On Thu, 4 Jul 2013, Wanpeng Li wrote:
>
>> This patch fix the callers that pass # of objects. Make sure they pass #
>> of slabs.
>
>Acked-by: Christoph Lameter <cl@linux.com>

Hi Pekka,

Is it ok for you to pick this patchset? ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
