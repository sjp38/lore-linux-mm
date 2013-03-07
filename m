Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id D938C6B0005
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 03:21:50 -0500 (EST)
Message-ID: <51384E3F.6070609@parallels.com>
Date: Thu, 7 Mar 2013 12:22:23 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH for 3.9] memcg: initialize kmem-cache destroying work
 earlier
References: <20130307074853.26272.83618.stgit@zurg>
In-Reply-To: <20130307074853.26272.83618.stgit@zurg>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On 03/07/2013 11:48 AM, Konstantin Khlebnikov wrote:
> This patch fixes warning from lockdep caused by calling cancel_work_sync()
> for uninitialized struct work. This path has been triggered by destructon
> kmem-cache hierarchy via destroying its root kmem-cache.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Glauber Costa <glommer@parallels.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> 
I see no reason not to do the work initialization earlier, so
ACK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
