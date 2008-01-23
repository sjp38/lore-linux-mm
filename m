In-reply-to: <4df4ef0c0801230237g2f26f0d1j2d2ada2ce62ba284@mail.gmail.com>
	(salikhmetov@gmail.com)
Subject: Re: [PATCH -v8 4/4] The design document for memory-mapped file times update
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
	 <1201044083554-git-send-email-salikhmetov@gmail.com>
	 <E1JHbs1-00025n-Ac@pomaz-ex.szeredi.hu> <4df4ef0c0801230237g2f26f0d1j2d2ada2ce62ba284@mail.gmail.com>
Message-Id: <E1JHdE4-0002Jk-QG@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 23 Jan 2008 11:53:00 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: miklos@szeredi.hu, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> I've already written in the cover letter that functional tests passed
> successfully.
>
> debian:~/times# ./times /mnt/file
> begin   1201084493      1201084493      1201084281
> write   1201084494      1201084494      1201084281
> mmap    1201084494      1201084494      1201084495
> b       1201084496      1201084496      1201084495

Ah, OK, this is becuase mmap doesn't actually set up the page tables
by default.   Try adding MAP_POPULATE to the flags.

Please also try

   ./times /mnt/file -s

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
