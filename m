Date: Tue, 6 Nov 2007 18:11:39 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC PATCH 0/10] split anon and file LRUs
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
Message-ID: <Pine.LNX.4.64.0711061808460.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 3 Nov 2007, Rik van Riel wrote:

> The current version only has the infrastructure.  Large changes to
> the page replacement policy will follow later.

Hmmmm.. I'd rather see where we are going. One other way of addressing 
many of these issues is to allow large page sizes on the LRU which will
reduce the number of entities that have to be managed. Both approaches 
actually would work in tandem.

> TODO:
> - have any mlocked and ramfs pages live off of the LRU list,
>   so we do not need to scan these pages

I think that is the most urgent issue at hand. At least for us.

> - switch to SEQ replacement for the anon LRU lists, so the
>   worst case number of pages to scan is reduced greatly.

No idea what that is?

> - figure out if the file LRU lists need page replacement
>   changes to help with worst case scenarios

We do not have an accepted standard load. So how would we figure that one 
out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
