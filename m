Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B5D18D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 16:28:47 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p2GKShka029154
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:28:43 -0700
Received: from pzk12 (pzk12.prod.google.com [10.243.19.140])
	by wpaz24.hot.corp.google.com with ESMTP id p2GKSI3U012168
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:28:42 -0700
Received: by pzk12 with SMTP id 12so448520pzk.24
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:28:41 -0700 (PDT)
Date: Wed, 16 Mar 2011 13:28:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/8] mm/slub: Remove unnecessary parameter
In-Reply-To: <20110316022805.27719.qmail@science.horizon.com>
Message-ID: <alpine.DEB.2.00.1103161315310.11002@chino.kir.corp.google.com>
References: <20110316022805.27719.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, herbert@gondor.hengli.com.au, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 14 Mar 2011, George Spelvin wrote:

> setup_object() does not need the page pointer.
> It's a private static function, so no API changes whatsoever.

This needs your signed-off-by line.

After that's fixed,

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
