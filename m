In-reply-to: <4df4ef0c0801170820i6af58e8u15e3c3b8e944c0c6@mail.gmail.com>
	(salikhmetov@gmail.com)
Subject: Re: [PATCH -v5 2/2] Updating ctime and mtime at syncing
References: <12005314662518-git-send-email-salikhmetov@gmail.com>
	 <1200531471556-git-send-email-salikhmetov@gmail.com>
	 <E1JFSgG-0006G1-6V@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170416s5581ae28h90d91578baa77738@mail.gmail.com>
	 <E1JFU7r-0006PK-So@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170516k3f82dc69ieee836b5633378a@mail.gmail.com>
	 <E1JFUrm-0006XG-SB@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801170540p36d3c566w973251527fc3bca1@mail.gmail.com>
	 <E1JFWvy-0006kJ-I2@pomaz-ex.szeredi.hu> <4df4ef0c0801170820i6af58e8u15e3c3b8e944c0c6@mail.gmail.com>
Message-Id: <E1JFXZd-0006pP-Sn@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 17 Jan 2008 17:26:37 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: miklos@szeredi.hu, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> The do_wp_page() function is called in mm/memory.c after locking PTE.
> And the file_update_time() routine calls the filesystem operation that can
> sleep. It's not accepted, I guess.

do_wp_page() is called with the pte lock but drops it, so that's fine.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
