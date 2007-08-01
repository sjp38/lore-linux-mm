Received: by rv-out-0910.google.com with SMTP id f1so40076rvb
        for <linux-mm@kvack.org>; Tue, 31 Jul 2007 19:19:07 -0700 (PDT)
Message-ID: <e28f90730707311919y7e48c7f9we4f974d844d17739@mail.gmail.com>
Date: Tue, 31 Jul 2007 23:19:00 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@gmail.com>
Subject: Re: [patch][rfc] remove ZERO_PAGE?
In-Reply-To: <20070801015306.GB24887@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070727021943.GD13939@wotan.suse.de>
	 <e28f90730707300652g4a0d0f4ah10bd3c06564d624b@mail.gmail.com>
	 <20070730115751.a2aaa28f.akpm@linux-foundation.org>
	 <20070730223912.GM2386@fieldses.org>
	 <20070801014739.GA30549@wotan.suse.de>
	 <20070801015306.GB24887@fieldses.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Andrea Arcangeli <andrea@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, lcapitulino@mandriva.com.br, Neil Brown <neilb@suse.de>
List-ID: <linux-mm.kvack.org>

On 7/31/07, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Aug 01, 2007 at 03:47:39AM +0200, Nick Piggin wrote:
> > On Mon, Jul 30, 2007 at 06:39:12PM -0400, J. Bruce Fields wrote:
> > > It looks to me like it's oopsing at the deference of
> > > fhp->fh_export->ex_uuid in encode_fsid(), which is exactly the case
> > > commit b41eeef14d claims to fix.  Looks like that's been in since
> > > v2.6.22-rc1; what kernel is this?
> >
> > Any progress with this? I'm fairly sure ZERO_PAGE removal wouldn't
> > have triggered it.
>
> I agree that it's most likely an nfsd bug.  I'll take another look, but
> it probably won't be till tommorow afternoon.

 Bruce, is there a way to reproduce the bug b41eeef14d claims to fix?

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
