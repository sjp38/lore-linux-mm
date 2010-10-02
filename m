Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC246B0047
	for <linux-mm@kvack.org>; Sat,  2 Oct 2010 04:50:10 -0400 (EDT)
Message-ID: <4CA6F240.5090702@kernel.org>
Date: Sat, 02 Oct 2010 11:50:08 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] slub: Fix signedness warnings
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Namhyung Kim <namhyung@gmail.com>, David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 29.9.2010 15.02, Namhyung Kim wrote:
> The bit-ops routines require its arg to be a pointer to unsigned long.
> This leads sparse to complain about different signedness as follows:
>
>   mm/slub.c:2425:49: warning: incorrect type in argument 2 (different signedness)
>   mm/slub.c:2425:49:    expected unsigned long volatile *addr
>   mm/slub.c:2425:49:    got long *map
>
> Signed-off-by: Namhyung Kim<namhyung@gmail.com>

The series has been applied. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
