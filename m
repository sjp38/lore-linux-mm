Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 6D5B26B005D
	for <linux-mm@kvack.org>; Wed, 12 Dec 2012 15:08:14 -0500 (EST)
Date: Wed, 12 Dec 2012 20:08:12 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [TRIVIAL PATCH 23/26] mm: Convert print_symbol to %pSR
In-Reply-To: <96a83ddb7f8571afe8b3b3b6e7fc9dc3ff81dda5.1355335228.git.joe@perches.com>
Message-ID: <0000013b90bb4f41-3c381041-b26d-4534-b983-a025858bb748-000000@email.amazonses.com>
References: <cover.1355335227.git.joe@perches.com> <96a83ddb7f8571afe8b3b3b6e7fc9dc3ff81dda5.1355335228.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Jiri Kosina <trivial@kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 12 Dec 2012, Joe Perches wrote:

> Use the new vsprintf extension to avoid any possible
> message interleaving.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
