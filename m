Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA53D6B0085
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 10:02:12 -0400 (EDT)
Message-ID: <4CAC815D.1040809@cs.helsinki.fi>
Date: Wed, 06 Oct 2010 17:02:05 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [UnifiedV4 01/16] slub: Enable sysfs support for !CONFIG_SLUB_DEBUG
References: <20101005185725.088808842@linux.com> <20101005185812.378496134@linux.com>
In-Reply-To: <20101005185812.378496134@linux.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On 5.10.2010 21.57, Christoph Lameter wrote:
> Currently disabling CONFIG_SLUB_DEBUG also disabled SYSFS support meaning
> that the slabs cannot be tuned without DEBUG.
>
> Make SYSFS support independent of CONFIG_SLUB_DEBUG
>
> Signed-off-by: Christoph Lameter<cl@linux.com>

I applied this patch. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
