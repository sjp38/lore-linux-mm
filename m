Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 8A7756B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:21:11 -0400 (EDT)
Message-ID: <5017E929.70602@parallels.com>
Date: Tue, 31 Jul 2012 18:18:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Any reason to use put_page in slub.c?
References: <1343391586-18837-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207271054230.18371@router.home> <50163D94.5050607@parallels.com> <alpine.DEB.2.00.1207301421150.27584@router.home> <5017968C.6050301@parallels.com> <alpine.DEB.2.00.1207310906350.32295@router.home> <5017E72D.2060303@parallels.com> <alpine.DEB.2.00.1207310915150.32295@router.home>
In-Reply-To: <alpine.DEB.2.00.1207310915150.32295@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 07/31/2012 06:17 PM, Christoph Lameter wrote:
> On Tue, 31 Jul 2012, Glauber Costa wrote:
> 
>> On 07/31/2012 06:09 PM, Christoph Lameter wrote:
>>> That is understood. Typically these object where page sized though and
>>> various assumptions (pretty dangerous ones as you are finding out) are
>>> made regarding object reuse. The fallback of SLUB for higher order allocs
>>> to the page allocator avoids these problems for higher order pages.
>> omg...
> 
> I would be very thankful if you would go through the tree and check for
> any remaining use cases like that. Would take care of your problem.

I would be happy to do it. Do you have any example of any user that
behaved like this in the past, so I can search for something similar?

This can potentially take many forms, and auditing every kfree out there
is not humanly possible. The best I can do is to search for known
patterns here...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
