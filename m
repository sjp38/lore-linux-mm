Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E1B7C6B005D
	for <linux-mm@kvack.org>; Wed, 11 Jul 2012 16:43:02 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so3077838pbb.14
        for <linux-mm@kvack.org>; Wed, 11 Jul 2012 13:43:02 -0700 (PDT)
Date: Wed, 11 Jul 2012 13:42:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slob: avoid type warning about alignment value
In-Reply-To: <201207110639.43587.arnd@arndb.de>
Message-ID: <alpine.DEB.2.00.1207111342180.3635@chino.kir.corp.google.com>
References: <201207102055.35278.arnd@arndb.de> <alpine.DEB.2.00.1207101815580.684@chino.kir.corp.google.com> <201207110639.43587.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

On Wed, 11 Jul 2012, Arnd Bergmann wrote:

> Also, size_t seems to be the correct type here, while the untyped
> definition is just an int.
> 

Ok, sounds good, thanks.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
