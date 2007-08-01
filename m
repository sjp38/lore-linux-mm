Subject: Re: [RFC PATCH] type safe allocator
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	<p73myxbpm8r.fsf@bingen.suse.de>
	<E1IGAx0-0006TK-00@dorka.pomaz.szeredi.hu>
From: Andi Kleen <andi@firstfloor.org>
Date: 01 Aug 2007 13:34:23 +0200
In-Reply-To: <E1IGAx0-0006TK-00@dorka.pomaz.szeredi.hu>
Message-ID: <p73643zpjy8.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: andi@firstfloor.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi <miklos@szeredi.hu> writes:
> 
> #define k_new(type, flags) ((type *) kmalloc(sizeof(type), flags))

The cast doesn't make it more safe in any way

(at least as long as you don't care about portability to C++;
the kernel doesn't)

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
