Date: Tue, 12 Oct 2004 13:20:27 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA: Patch for node based swapping
In-Reply-To: <Pine.LNX.4.44.0410121151220.13693-100000@chimarrao.boston.redhat.com>
Message-ID: <Pine.LNX.4.58.0410121319510.5785@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0410121151220.13693-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Oct 2004, Rik van Riel wrote:

> On Tue, 12 Oct 2004, Christoph Lameter wrote:
>
> > Any other suggestions?
>
> Since this is meant as a stop gap patch, waiting for a real
> solution, and is only relevant for big (and rare) systems,
> it would be an idea to at least leave it off by default.
>
> I think it would be safe to assume that a $100k system has
> a system administrator looking after it, while a $5k AMD64
> whitebox might not have somebody watching its performance.

Ok. Will do that then. Should I submit the patch to Andrew?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
