Date: Wed, 31 Oct 2007 14:07:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Interesting Bug in page migration via mbind()
In-Reply-To: <1193863506.5299.139.camel@localhost>
Message-ID: <Pine.LNX.4.64.0710311406570.22599@schroedinger.engr.sgi.com>
References: <1193863506.5299.139.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andi Kleen <ak@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 31 Oct 2007, Lee Schermerhorn wrote:

> How to address?

Looks like we are not updating the vma information correctly when 
splitting vmas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
