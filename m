Received: by wr-out-0506.google.com with SMTP id c8so297640wra.26
        for <linux-mm@kvack.org>; Thu, 10 Jan 2008 08:08:19 -0800 (PST)
Message-ID: <170fa0d20801100808x7330589fj8f6884f56a194e76@mail.gmail.com>
Date: Thu, 10 Jan 2008 11:08:18 -0500
From: "Mike Snitzer" <snitzer@gmail.com>
Subject: Re: [patch 00/19] VM pageout scalability improvements
In-Reply-To: <20080110104155.34b5cede@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080108205939.323955454@redhat.com>
	 <170fa0d20801092039w22584e2fw6821e70157f55cae@mail.gmail.com>
	 <20080110104155.34b5cede@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Jan 10, 2008 10:41 AM, Rik van Riel <riel@redhat.com> wrote:
>
> On Wed, 9 Jan 2008 23:39:02 -0500
> "Mike Snitzer" <snitzer@gmail.com> wrote:
>
> > How much trouble am I asking for if I were to try to get your patchset
> > to fly on a fairly recent "stable" kernel (e.g. 2.6.22.15)?  If
> > workable, is such an effort before it's time relative to your TODO?
>
> Quite a bit :)
>
> The -mm kernel has the memory controller code, which means the
> mm/ directory is fairly different.  My patch set sits on top
> of that.
>
> Chances are that once the -mm kernel goes upstream (in 2.6.25-rc1),
> I can start building on top of that.
>
> OTOH, maybe I could get my patch series onto a recent 2.6.23.X with
> minimal chainsaw effort.

That would be great!  I can't speak for others but -mm poses a problem
for testing your patchset because it is so bleeding.  Let me know if
you take the plunge on a 2.6.23.x backport; I'd really appreciate it.

Is anyone else interested in consuming a 2.6.23.x backport of Rik's
patchset?  If so please speak up.

> > I see that you have an old port to a FC7-based 2.6.21 here:
> > http://people.redhat.com/riel/vmsplit/
> >
> > Also, do you have a public git repo that you regularly publish to for
> > this patchset?  If not a git repo do you put the raw patchset on some
> > http/ftp server?
>
> Up to now I have only emailed out the patches. Since there is demand
> for them to be downloadable from somewhere, I'll also start putting
> them on http://people.redhat.com/riel/

Great, thanks.

Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
