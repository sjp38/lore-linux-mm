Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id D9F1A6B0044
	for <linux-mm@kvack.org>; Fri,  3 Aug 2012 09:12:34 -0400 (EDT)
Message-ID: <501BCD93.8040303@parallels.com>
Date: Fri, 3 Aug 2012 17:09:39 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/19] Sl[auo]b: Common code rework V9
References: <20120802201506.266817615@linux.com>
In-Reply-To: <20120802201506.266817615@linux.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/03/2012 12:15 AM, Christoph Lameter wrote:
> Note that the first three patches are candidates
> for 3.5 since they fix certain things.
> The rest could go into -next once we are
> through with initial review.
> 
> V8->V9:
> - Fix numerous things pointed out by Glauber.
Unfortunately you didn't, the issue I reported to you is still present.
In any case, I am happy that it helped you to sort out *other* issues =)

I took the time to debug this today, and already found the problem. I'll
comment in the relevant patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
