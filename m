Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 66FE46B0032
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 19:30:08 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 09:20:58 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 15D363578051
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 09:30:02 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r63NF1f357606252
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 09:15:02 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r63NU0Ec014696
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 09:30:00 +1000
Date: Thu, 4 Jul 2013 07:29:59 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 1/5] mm/slab: Fix drain freelist excessively
Message-ID: <20130703232959.GA28837@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <0000013fa4cffd1e-e2977e3b-748a-4b7e-9ee6-669b41912abc-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013fa4cffd1e-e2977e3b-748a-4b7e-9ee6-669b41912abc-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 03, 2013 at 01:54:22PM +0000, Christoph Lameter wrote:
>On Wed, 3 Jul 2013, Wanpeng Li wrote:
>
>> This patch fix the callers that pass # of objects. Make sure they pass #
>> of slabs.
>
>Hmm... These modifications are all the same. Create a new function?

Ok, I will introduce a helper function, thanks for your review,
Christoph. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
