Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 3ED9E6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 10:25:21 -0500 (EST)
Date: Wed, 23 Jan 2013 15:25:19 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 1/3] slub: correct to calculate num of acquired objects
 in get_partial_node()
In-Reply-To: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000013c68036988-0c4473ce-1dc9-4967-b321-551196dc2830-000000@email.amazonses.com>
References: <1358755287-3899-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 21 Jan 2013, Joonsoo Kim wrote:

> v2: calculate nr of objects using new.objects and new.inuse.
> It is more accurate way than before.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
