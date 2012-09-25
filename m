Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id E5FC36B0062
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 12:26:49 -0400 (EDT)
Date: Tue, 25 Sep 2012 16:26:48 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: Ignore internal flags in cache creation
In-Reply-To: <1348571866-31738-1-git-send-email-glommer@parallels.com>
Message-ID: <00000139fe408877-40bc98e3-322c-4ba2-be72-e298ff28e694-000000@email.amazonses.com>
References: <1348571866-31738-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>

On Tue, 25 Sep 2012, Glauber Costa wrote:

> No cache should ever pass those as a creation flags. We can just ignore
> this bit if it happens to be passed (such as when duplicating a cache in
> the kmem memcg patches)

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
