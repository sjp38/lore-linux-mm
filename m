In-reply-to: <12006091182260-git-send-email-salikhmetov@gmail.com> (message
	from Anton Salikhmetov on Fri, 18 Jan 2008 01:31:56 +0300)
Subject: Re: [PATCH -v6 0/2] Fixing the issue with memory-mapped file times
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
Message-Id: <E1JFnho-0008TH-5G@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 18 Jan 2008 10:40:08 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: salikhmetov@gmail.com
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> 4. Performance test was done using the program available from the
> following link:
> 
> http://bugzilla.kernel.org/attachment.cgi?id=14493
> 
> Result: the impact of the changes was negligible for files of a few
> hundred megabytes.

Could you also test with ext4 and post some numbers?  Afaik, ext4 uses
nanosecond timestamps, so the time updating code would be exercised
more during the page faults.

What about performance impact on msync(MS_ASYNC)?  Could you please do
some measurment of that as well?

Thanks,
Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
