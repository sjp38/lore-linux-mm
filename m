Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 53DBF6B0036
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 09:59:36 -0400 (EDT)
Date: Wed, 3 Jul 2013 13:59:34 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 4/5] mm/slub: Drop unnecessary nr_partials
In-Reply-To: <1372812593-7617-4-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <0000013fa4d4c30f-dcf88f6c-01db-474a-a39b-a05dca34f064-000000@email.amazonses.com>
References: <1372812593-7617-1-git-send-email-liwanp@linux.vnet.ibm.com> <1372812593-7617-4-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 3 Jul 2013, Wanpeng Li wrote:

> This patch remove unused nr_partials variable.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
