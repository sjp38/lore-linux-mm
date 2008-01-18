Received: by wa-out-1112.google.com with SMTP id m33so1638409wag.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 02:31:30 -0800 (PST)
Message-ID: <4df4ef0c0801180231j46391b2byc38be709b3cbf2c8@mail.gmail.com>
Date: Fri, 18 Jan 2008 13:31:29 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v6 0/2] Fixing the issue with memory-mapped file times
In-Reply-To: <E1JFnho-0008TH-5G@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <E1JFnho-0008TH-5G@pomaz-ex.szeredi.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/18, Miklos Szeredi <miklos@szeredi.hu>:
> > 4. Performance test was done using the program available from the
> > following link:
> >
> > http://bugzilla.kernel.org/attachment.cgi?id=14493
> >
> > Result: the impact of the changes was negligible for files of a few
> > hundred megabytes.
>
> Could you also test with ext4 and post some numbers?  Afaik, ext4 uses
> nanosecond timestamps, so the time updating code would be exercised
> more during the page faults.
>
> What about performance impact on msync(MS_ASYNC)?  Could you please do
> some measurment of that as well?

I'll do the measurements for the MS_ASYNC case and for the Ext4 filesystem.

>
> Thanks,
> Miklos
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
