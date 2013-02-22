Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B56836B0006
	for <linux-mm@kvack.org>; Fri, 22 Feb 2013 11:34:48 -0500 (EST)
Date: Fri, 22 Feb 2013 16:34:47 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slub: correctly bootstrap boot caches
In-Reply-To: <1361550000-14173-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013d02c1c9be-1a06ac46-e42b-4174-8a41-bc5b22ad36ad-000000@email.amazonses.com>
References: <1361550000-14173-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@kernel.org>

On Fri, 22 Feb 2013, Glauber Costa wrote:

> After we create a boot cache, we may allocate from it until it is bootstraped.
> This will move the page from the partial list to the cpu slab list. If this
> happens, the loop:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
