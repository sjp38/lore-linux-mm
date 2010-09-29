Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E69026B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 08:18:11 -0400 (EDT)
Date: Wed, 29 Sep 2010 07:18:07 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slub: Fix signedness warnings
In-Reply-To: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
Message-ID: <alpine.DEB.2.00.1009290717230.30155@router.home>
References: <1285761735-31499-1-git-send-email-namhyung@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Namhyung Kim <namhyung@gmail.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Namhyung Kim wrote:

> The bit-ops routines require its arg to be a pointer to unsigned long.
> This leads sparse to complain about different signedness as follows:

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
