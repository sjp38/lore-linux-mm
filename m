Received: by nz-out-0506.google.com with SMTP id i11so1508620nzh.26
        for <linux-mm@kvack.org>; Tue, 15 Jan 2008 12:12:03 -0800 (PST)
Message-ID: <4df4ef0c0801151212y64d0a75dsced9f00e7aec431c@mail.gmail.com>
Date: Tue, 15 Jan 2008 23:12:02 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH 1/2] Massive code cleanup of sys_msync()
In-Reply-To: <20080115193204.GA25866@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12004129652397-git-send-email-salikhmetov@gmail.com>
	 <12004129734126-git-send-email-salikhmetov@gmail.com>
	 <20080115175705.GA21557@infradead.org>
	 <4df4ef0c0801151102l4d72b6b5j702e21beb1ebe459@mail.gmail.com>
	 <20080115111018.1e27a229.randy.dunlap@oracle.com>
	 <4df4ef0c0801151126p5dfdbc13ga9862c995890c33c@mail.gmail.com>
	 <1200425328.26045.39.camel@twins>
	 <20080115193204.GA25866@infradead.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu
List-ID: <linux-mm.kvack.org>

2008/1/15, Christoph Hellwig <hch@infradead.org>:
> On Tue, Jan 15, 2008 at 08:28:48PM +0100, Peter Zijlstra wrote:
> > Notice that error is already -EINVAL, so a simple goto should suffice.
>
> Yes, for the start of the function you can basically leave it as-is.
>

OK, I will do as you suggest. Thank you for your answers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
