Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id DF7006B0027
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 23:26:46 -0400 (EDT)
Message-ID: <51662DA3.40003@parallels.com>
Date: Thu, 11 Apr 2013 07:27:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [ATTEND][LSF/MM TOPIC] the memory controller
References: <510632BD.3010702@parallels.com>
In-Reply-To: <510632BD.3010702@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org

On 01/28/2013 12:11 PM, Lord Glauber Costa of Sealand wrote:
> Hi,
> 
> I've been working actively over the past year with the memory
> controller, in particular its usage to track special bits of interest in
> kernel memory land. As this work progress, I'd like to propose and
> participate in the following discussions in the upcoming LSF/MM:
> 
> * memcg kmem shrinking: as memory pressure appears within memcg, we need
> to shrink some of the slab objects attributed to the group, maintaining
> isolation as much as possible. The scheme also needs to allow for global
> reclaim to keep working reliably, and of course, be memory efficient.
> 

I have already posted some versions of it, that got quite some positive
feedback(*), at least from the MM side. Shrinking is something that can
be of interest for both mm and fs people, so maybe we could benefit for
having some joint discussion about it

* http://lwn.net/Articles/546472/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
