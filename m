Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4F5066007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 13:17:20 -0400 (EDT)
Message-ID: <4C72AD0D.7040100@cs.helsinki.fi>
Date: Mon, 23 Aug 2010 20:17:01 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [S+Q Cleanup4 0/6] SLUB: Cleanups V4
References: <20100820173711.136529149@linux.com>
In-Reply-To: <20100820173711.136529149@linux.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 20.8.2010 20.37, Christoph Lameter wrote:
> I think it may be best to first try to merge these and make sure that
> they are fine before we go step by step through the unification patches.
> I hope they can go into -next.

I've applied these patches and queued them for -next. Thanks guys!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
