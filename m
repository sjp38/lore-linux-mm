Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id E6F0B6B0032
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 09:24:49 -0400 (EDT)
Date: Mon, 29 Apr 2013 15:24:47 +0200 (CEST)
From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: [TRIVIAL PATCH 23/26] mm: Convert print_symbol to %pSR
In-Reply-To: <0000013b90bb4f41-3c381041-b26d-4534-b983-a025858bb748-000000@email.amazonses.com>
Message-ID: <alpine.LNX.2.00.1304291524360.11889@pobox.suse.cz>
References: <cover.1355335227.git.joe@perches.com> <96a83ddb7f8571afe8b3b3b6e7fc9dc3ff81dda5.1355335228.git.joe@perches.com> <0000013b90bb4f41-3c381041-b26d-4534-b983-a025858bb748-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Joe Perches <joe@perches.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 12 Dec 2012, Christoph Lameter wrote:

> > Use the new vsprintf extension to avoid any possible
> > message interleaving.
> 
> Acked-by: Christoph Lameter <cl@linux.com>

Doesn't seem to be in linux-next as of today, I am taking this one.

-- 
Jiri Kosina
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
