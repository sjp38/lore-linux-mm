Date: Fri, 21 Sep 2007 12:15:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/9] oom killer serialization
In-Reply-To: <20070921021208.e6fec547.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709211214490.17518@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709201318090.25753@chino.kir.corp.google.com>
 <20070921021208.e6fec547.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, Andrew Morton wrote:

> What's the relationship between this patch series and Andrea's monster
> oomkiller patchset?  Looks like teeny-subset-plus-other-stuff?

I think we need to know from Andrea if our work addresses all the issues 
that he has seen.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
