Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 704ED6B0033
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 19:45:20 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 09:36:14 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 98A352BB004F
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 09:45:15 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r61NU9ju4784620
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 09:30:09 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r61NjE2j024813
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 09:45:15 +1000
Date: Tue, 2 Jul 2013 07:45:13 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm/slab: Fix drain freelist excessively
Message-ID: <20130701234513.GB14358@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <0000013f9aea494f-7a5fe6c7-47d2-42a9-bbe6-5dbc85dab0a5-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f9aea494f-7a5fe6c7-47d2-42a9-bbe6-5dbc85dab0a5-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 01, 2013 at 03:46:52PM +0000, Christoph Lameter wrote:
>On Mon, 24 Jun 2013, Wanpeng Li wrote:
>
>> The drain_freelist is called to drain slabs_free lists for cache reap,
>> cache shrink, memory hotplug callback etc. The tofree parameter is the
>> number of slab objects to free instead of the number of slabs to free.
>
>Well its intended to be the number of slabs to free. The patch does not
>fix the callers that pass the number of slabs.
>
>I think the best approach would be to fix the callers that pass # of
>objects. Make sure they pass # of slabs.
>

Good point, I will fix it in next version.

Regards,
Wanpeng Li 

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
