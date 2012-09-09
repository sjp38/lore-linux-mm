Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 94C3F6B0062
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 17:27:59 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1697789pbb.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 14:27:58 -0700 (PDT)
Date: Sun, 9 Sep 2012 14:27:55 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 02/10] mm, slob: Use NUMA_NO_NODE instead of -1
In-Reply-To: <1347137279-17568-2-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209091427160.13346@chino.kir.corp.google.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com> <1347137279-17568-2-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Sat, 8 Sep 2012, Ezequiel Garcia wrote:

> Cc: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

Please cc Matt Mackall <mpm@selenic.com> on all slob patches in the 
future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
