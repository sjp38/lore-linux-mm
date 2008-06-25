In-reply-to: <20080625141054.GB20851@kernel.dk> (message from Jens Axboe on
	Wed, 25 Jun 2008 16:10:54 +0200)
Subject: Re: generic_file_splice_read() issues
References: <E1KBVRu-0005y4-1i@pomaz-ex.szeredi.hu> <20080625141054.GB20851@kernel.dk>
Message-Id: <E1KBVwv-0006De-6e@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 25 Jun 2008 16:26:17 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: jens.axboe@oracle.com
Cc: miklos@szeredi.hu, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Perhaps we can abstract that bit out into a small helper function, tied
> in with your previous patch.

If you don't mind, I'd leave this to you.  I don't have the means (and
time) to test these changes, and anyway my preferred solution to all
known and unknown problems of generic_file_splice_read() would be to
move it to do_generic_file_read(), which you and Linus unfortunately
don't like :/

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
