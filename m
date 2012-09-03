Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id D1FA26B0062
	for <linux-mm@kvack.org>; Mon,  3 Sep 2012 11:13:06 -0400 (EDT)
Message-ID: <5044C844.10508@parallels.com>
Date: Mon, 3 Sep 2012 19:09:56 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C13 [11/14] Move sysfs_slab_add to common
References: <20120824160903.168122683@linux.com> <00000139596c66ee-862b5103-18d2-4d88-88cb-e8728f0f54f8-000000@email.amazonses.com>
In-Reply-To: <00000139596c66ee-862b5103-18d2-4d88-88cb-e8728f0f54f8-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/24/2012 08:17 PM, Christoph Lameter wrote:
> Simplify locking by moving the slab_add_sysfs after all locks
> have been dropped. Eases the upcoming move to provide sysfs
> support for all allocators.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Makes sense.

Reviewed-by: Glauber Costa <glommer@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
