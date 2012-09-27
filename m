Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id CCE296B0074
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 10:51:56 -0400 (EDT)
Date: Thu, 27 Sep 2012 14:51:55 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/4] sl[au]b: move print_slabinfo_header to
 slab_common.c
In-Reply-To: <1348756660-16929-3-git-send-email-glommer@parallels.com>
Message-ID: <0000013a08366d0c-86e9d762-0a40-4276-97d1-6ac651847857-000000@email.amazonses.com>
References: <1348756660-16929-1-git-send-email-glommer@parallels.com> <1348756660-16929-3-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 27 Sep 2012, Glauber Costa wrote:

> By making sure that information conditionally lives inside a
> globally-visible CONFIG_DEBUG_SLAB switch, we can move the header
> printing to a common location.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
