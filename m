Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9C45F6B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:04:51 -0400 (EDT)
Subject: Re: [PATCH] mm/slub.c: Use print_hex_dump and remove unnecessary
 cast
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <1242840314-25635-1-git-send-email-joe@perches.com>
References: <1242840314-25635-1-git-send-email-joe@perches.com>
Date: Fri, 22 May 2009 11:04:52 +0300
Message-Id: <1242979492.13681.3.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, H Hartley Sweeten <hartleys@visionengravers.com>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, David Rientjes <rientjes@google.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-20 at 10:25 -0700, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  mm/slub.c |   34 ++++------------------------------
>  1 files changed, 4 insertions(+), 30 deletions(-)

I am more than happy to merge this patch if the hexdump issues are
resolved.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
