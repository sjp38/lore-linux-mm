Received: by wa-out-1112.google.com with SMTP id m33so1637862wag.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 02:30:20 -0800 (PST)
Message-ID: <4df4ef0c0801180230r516085f0s3e6b919c395f33d2@mail.gmail.com>
Date: Fri, 18 Jan 2008 13:30:19 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v6 1/2] Massive code cleanup of sys_msync()
In-Reply-To: <E1JFnbj-0008SD-57@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <12006091213248-git-send-email-salikhmetov@gmail.com>
	 <E1JFnbj-0008SD-57@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/18, Miklos Szeredi <miklos@szeredi.hu>:
> >       unsigned long end;
> > -     struct mm_struct *mm = current->mm;
> > +     int error, unmapped_error;
> >       struct vm_area_struct *vma;
> > -     int unmapped_error = 0;
> > -     int error = -EINVAL;
> > +     struct mm_struct *mm;
> >
> > +     error = -EINVAL;
>
> I think you may have misunderstood my last comment.  These are OK:
>
>         struct mm_struct *mm = current->mm;
>         int unmapped_error = 0;
>         int error = -EINVAL;
>
> This is not so good:
>
>         int error, unmapped_error;
>
> This is the worst:
>
>         int error = -EINVAL, unmapped_error = 0;
>
> So I think the original code is fine as it is.
>
> Othewise patch looks OK now.

I moved the initialization of the variables to the code where they are needed.

I don't agree that "int a; int b;" is better than "int a, b".

>
> Miklos
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
