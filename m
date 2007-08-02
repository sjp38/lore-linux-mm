Date: Thu, 2 Aug 2007 11:36:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] type safe allocator
Message-Id: <20070802113626.634a6bd9.akpm@linux-foundation.org>
In-Reply-To: <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	<E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 02 Aug 2007 13:31:56 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> The linux kernel doesn't have a type safe object allocator a-la new()
> in C++ or g_new() in glib.
> 
> Introduce two helpers for this purpose:
> 
>    alloc_struct(type, gfp_flags);
> 
>    zalloc_struct(type, gfp_flags);

whimper.

On a practical note, I'm still buried in convert-to-kzalloc patches, and
your proposal invites a two-year stream of 10,000 convert-to-alloc_struct
patches.

So if this goes in (and I can't say I'm terribly excited about the idea)
then I think we'd also need a maintainer who is going to handle all the
subsequent patches, run a git tree, (a quilt tree would be better, or maybe
a git tree with 100 branches), work with all the affected maintainers, make
sure there aren't clashes with other people's work and all that blah.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
