Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 5A5526B006E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 10:36:38 -0500 (EST)
Date: Tue, 15 Jan 2013 15:36:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/3] slub: add 'likely' macro to inc_slabs_node()
In-Reply-To: <1358234402-2615-3-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <0000013c3edaddec-dc190a12-1fc1-4a9e-aa19-dd74c374c499-000000@email.amazonses.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com> <1358234402-2615-3-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 15 Jan 2013, Joonsoo Kim wrote:

> After boot phase, 'n' always exist.
> So add 'likely' macro for helping compiler.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
