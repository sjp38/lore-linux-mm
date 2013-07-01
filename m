Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 1F5356B0036
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 14:47:02 -0400 (EDT)
Date: Mon, 1 Jul 2013 18:47:00 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] mm/slub: Use node_nr_slabs and node_nr_objs in
 get_slabinfo
In-Reply-To: <1372291059-9880-3-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <0000013f9b8f30b1-0126933f-98c9-4bf1-b475-daa3accd3724-000000@email.amazonses.com>
References: <1372291059-9880-1-git-send-email-liwanp@linux.vnet.ibm.com> <1372291059-9880-3-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 27 Jun 2013, Wanpeng Li wrote:

> Use existing interface node_nr_slabs and node_nr_objs to get
> nr_slabs and nr_objs.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
