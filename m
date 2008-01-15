Received: by wa-out-1112.google.com with SMTP id m33so4406577wag.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 02:46:34 -0800 (PST)
Message-ID: <4df4ef0c0801150246r56675627nf669812ec9daff89@mail.gmail.com>
Date: Tue, 15 Jan 2008 13:46:34 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 2/2] updating ctime and mtime at syncing
In-Reply-To: <E1JEiUT-0000qO-MY@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12001991991217-git-send-email-salikhmetov@gmail.com>
	 <12001992023392-git-send-email-salikhmetov@gmail.com>
	 <E1JENAv-0007CM-T9@pomaz-ex.szeredi.hu>
	 <4df4ef0c0801140422l1980d507v1884ad8d8e8bf6d3@mail.gmail.com>
	 <E1JEP9P-0007RD-PP@pomaz-ex.szeredi.hu>
	 <1200317737.15103.8.camel@twins>
	 <4df4ef0c0801140617t6ca81e84w1cdfcce290ce68fe@mail.gmail.com>
	 <E1JEiUT-0000qO-MY@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com
List-ID: <linux-mm.kvack.org>

2008/1/15, Miklos Szeredi <miklos@szeredi.hu>:
> > Thanks for your review, Peter and Miklos!
> >
> > I overlooked this case when AS_MCTIME flag has been turned off and the
> > page is still dirty.
> >
> > On the other hand, the words "shall be marked for update" may be
> > considered as just setting the AS_MCTIME flag, not updating the time
> > stamps.
> >
> > What do you think about calling mapping_update_time() inside of "if
> > (MS_SYNC & flags)"? I suggest such change because the code for
> > analysis of the case you've mentioned above seems impossible to me.
>
> I think that's a good idea.  As a first iteration, just updating the
> mtime/ctime in msync(MS_SYNC) and remove_vma() (called at munmap time)
> would be a big improvement over what we currently have.
>
> I would also recommend, that you drop mapping_update_time() and the
> related functions from the patch, and just use file_update_time()
> instead.

Thank you for your recommendations. I will submit my new solution shortly.

By the way, I've already changed the unlink_file_vma() function.

>
> Miklos
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
