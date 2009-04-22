Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE9E56B00E6
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 10:37:04 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1157551yxh.26
        for <linux-mm@kvack.org>; Wed, 22 Apr 2009 07:37:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1240408407-21848-23-git-send-email-mel@csn.ul.ie>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie>
	 <1240408407-21848-23-git-send-email-mel@csn.ul.ie>
Date: Wed, 22 Apr 2009 17:37:38 +0300
Message-ID: <84144f020904220737t3657ac01j4edf86cf61ef15e0@mail.gmail.com>
Subject: Re: [PATCH 22/22] slab: Use nr_online_nodes to check for a NUMA
	platform
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 22, 2009 at 4:53 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> SLAB currently avoids checking a bitmap repeatedly by checking once and
> storing a flag. When the addition of nr_online_nodes as a cheaper version
> of num_online_nodes(), this check can be replaced by nr_online_nodes.
>
> (Christoph did a patch that this is lifted almost verbatim from, hence the
> first Signed-off-by. Christoph, can you confirm you're ok with that?)
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
