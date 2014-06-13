Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 147FA6B00C1
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 09:00:37 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so2268896wib.0
        for <linux-mm@kvack.org>; Fri, 13 Jun 2014 06:00:37 -0700 (PDT)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [2002:c35c:fd02::1])
        by mx.google.com with ESMTPS id cg8si1795550wib.8.2014.06.13.06.00.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Jun 2014 06:00:36 -0700 (PDT)
Date: Fri, 13 Jun 2014 14:00:26 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: mm/fs: gpf when shrinking slab
Message-ID: <20140613130026.GF18016@ZenIV.linux.org.uk>
References: <539AF460.4000400@oracle.com>
 <539AF4A6.9060707@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <539AF4A6.9060707@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>

On Fri, Jun 13, 2014 at 08:55:02AM -0400, Sasha Levin wrote:
> Hand too fast on the trigger... sorry.
> 
> It happened while fuzzing inside a KVM tools guest on the latest -next kernel. Seems
> to be pretty difficult to reproduce.

Does that kernel contain c2338f?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
