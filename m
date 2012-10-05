Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C18806B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 15:00:09 -0400 (EDT)
Date: Fri, 5 Oct 2012 19:00:08 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v4] slab: Ignore internal flags in cache creation
In-Reply-To: <1349434154-8000-1-git-send-email-glommer@parallels.com>
Message-ID: <0000013a324c8c9a-26b4f363-3799-40a9-843a-66dc79770170-000000@email.amazonses.com>
References: <1349434154-8000-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 5 Oct 2012, Glauber Costa wrote:

> Common code will mask out all flags not belonging to that set.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
