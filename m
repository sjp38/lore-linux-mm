In-reply-to: <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu> (message from Miklos
	Szeredi on Tue, 21 Oct 2008 18:20:17 +0200)
Subject: Re: [patch] fs: improved handling of page and buffer IO errors
References: <20081021112137.GB12329@wotan.suse.de> <E1KsGj7-0005sK-Uq@pomaz-ex.szeredi.hu> <20081021125915.GA26697@fogou.chygwyn.com> <E1KsH4S-0005ya-6F@pomaz-ex.szeredi.hu> <20081021133814.GA26942@fogou.chygwyn.com> <20081021143518.GA7158@2ka.mipt.ru> <20081021145901.GA28279@fogou.chygwyn.com> <E1KsJxx-0006l4-NH@pomaz-ex.szeredi.hu>
Message-Id: <E1KsK5R-0006mR-AO@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 21 Oct 2008 18:28:01 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: steve@chygwyn.com
Cc: zbr@ioremap.net, miklos@szeredi.hu, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Oct 2008, Miklos Szeredi wrote:
> BTW, why do you want strict coherency for memory mappings?  It's not
> something POSIX mandates.  It's not even something that Linux always
> did.

Or does, for that matter, on those architectures which have virtually
addressed caches.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
