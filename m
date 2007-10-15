From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH resend] ramdisk: fix zeroed ramdisk pages on memory pressure
Date: Tue, 16 Oct 2007 01:23:32 +1000
References: <200710151028.34407.borntraeger@de.ibm.com> <200710160006.19735.nickpiggin@yahoo.com.au> <20071015021624.7d5233bd.akpm@linux-foundation.org>
In-Reply-To: <20071015021624.7d5233bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710160123.32434.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Theodore Ts'o <tytso@mit.edu>
List-ID: <linux-mm.kvack.org>

On Monday 15 October 2007 19:16, Andrew Morton wrote:
> On Tue, 16 Oct 2007 00:06:19 +1000 Nick Piggin <nickpiggin@yahoo.com.au> 
wrote:
> > On Monday 15 October 2007 18:28, Christian Borntraeger wrote:
> > > Andrew, this is a resend of a bugfix patch. Ramdisk seems a bit
> > > unmaintained, so decided to sent the patch to you :-).
> > > I have CCed Ted, who did work on the code in the 90s. I found no
> > > current email address of Chad Page.
> >
> > This really needs to be fixed...
>
> rd.c is fairly mind-boggling vfs abuse.

Why do you say that? I guess it is _different_, by necessity(?)
Is there anything that is really bad? I guess it's not nice
for operating on the pagecache from its request_fn, but the
alternative is to duplicate pages for backing store and buffer
cache (actually that might not be a bad alternative really).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
