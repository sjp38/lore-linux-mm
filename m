In-reply-to: <20070802113626.634a6bd9.akpm@linux-foundation.org> (message from
	Andrew Morton on Thu, 2 Aug 2007 11:36:26 -0700)
Subject: Re: [PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	<E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu> <20070802113626.634a6bd9.akpm@linux-foundation.org>
Message-Id: <E1IGfik-0002Y1-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 02 Aug 2007 20:48:26 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: miklos@szeredi.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> > The linux kernel doesn't have a type safe object allocator a-la new()
> > in C++ or g_new() in glib.
> > 
> > Introduce two helpers for this purpose:
> > 
> >    alloc_struct(type, gfp_flags);
> > 
> >    zalloc_struct(type, gfp_flags);
> 
> whimper.
> 
> On a practical note, I'm still buried in convert-to-kzalloc patches, and
> your proposal invites a two-year stream of 10,000 convert-to-alloc_struct
> patches.
> 
> So if this goes in

No, I gave up.  It seems nobody likes the idea except me :(

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
