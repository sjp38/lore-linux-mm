Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6819C6B0008
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 12:45:37 -0500 (EST)
Message-ID: <512BA33C.6060506@redhat.com>
Date: Mon, 25 Feb 2013 12:45:32 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: slab: Verify the nodeid passed to ____cache_alloc_node
References: <591256534.8212978.1361812690861.JavaMail.root@redhat.com>
In-Reply-To: <591256534.8212978.1361812690861.JavaMail.root@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, glommer@parallels.com

On 02/25/2013 12:18 PM, Aaron Tomlin wrote:

> mm: slab: Verify the nodeid passed to ____cache_alloc_node
>
> If the nodeid is > num_online_nodes() this can cause an
> Oops and a panic(). The purpose of this patch is to assert
> if this condition is true to aid debugging efforts rather
> than some random NULL pointer dereference or page fault.
>
> Signed-off-by: Aaron Tomlin <atomlin@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
