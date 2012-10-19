Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 30C4D6B005D
	for <linux-mm@kvack.org>; Fri, 19 Oct 2012 06:38:24 -0400 (EDT)
Message-ID: <50812D97.9060004@parallels.com>
Date: Fri, 19 Oct 2012 14:38:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/3] move slabinfo processing to common code
References: <1348844608-12568-1-git-send-email-glommer@parallels.com>
In-Reply-To: <1348844608-12568-1-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 09/28/2012 07:03 PM, Glauber Costa wrote:
> Hi,
> 
> This patch moves on with the slab caches commonization, by moving
> the slabinfo processing to common code in slab_common.c. It only touches
> slub and slab, since slob doesn't create that file, which is protected
> by a Kconfig switch.
> 
> Enjoy,
> 
> v2: return objects per slab and cache order in slabinfo structure as well
> 
Hi

Any activity here ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
