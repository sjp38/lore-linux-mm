Date: Thu, 10 Apr 2003 13:34:55 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] bootmem speedup from the IA64 tree
Message-ID: <45550000.1050006895@flay>
In-Reply-To: <20030410134334.37c86863.akpm@digeo.com>
References: <20030410122421.A17889@lst.de><20030410095930.D9136@redhat.com> <20030410134334.37c86863.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, Benjamin LaHaise <bcrl@redhat.com>
Cc: hch@lst.de, davidm@napali.hpl.hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Bootmem igornamus says:
> 
> Do we have a problem with using an `unsigned long' byte address in there on
> ia32 PAE?  Or are we guaranteed that this will only ever be used in the lower
> 4G of physical memory?

IIRC, only ZONE_NORMAL goes into bootmem, so we should be OK.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
