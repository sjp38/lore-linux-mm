Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0346007EE
	for <linux-mm@kvack.org>; Mon, 23 Aug 2010 13:18:23 -0400 (EDT)
Message-ID: <4C72AD4D.2000702@cs.helsinki.fi>
Date: Mon, 23 Aug 2010 20:18:05 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [S+Q Core 3/6] slub: Get rid of useless function count_free()
References: <20100820190151.493325014@linux.com> <20100820190235.573083017@linux.com>
In-Reply-To: <20100820190235.573083017@linux.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On 20.8.2010 22.01, Christoph Lameter wrote:
> count_free() == available()
>
> Signed-off-by: Christoph Lameter<cl@linux-foundation.org>

I think you can squash this to patch one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
