Subject: Re: Consistent page aging....
References: <Pine.LNX.4.33L.0107251249180.20326-100000@duckman.distro.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 25 Jul 2001 10:08:13 -0600
In-Reply-To: <Pine.LNX.4.33L.0107251249180.20326-100000@duckman.distro.conectiva>
Message-ID: <m18zhdgff6.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On Wed, 25 Jul 2001, Marcelo Tosatti wrote:
> > On 25 Jul 2001, Eric W. Biederman wrote:
> > > Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> > >
> > > > We had to be able to age pages without allocating swap space...
> > >
> > > I don't see any technical reasons why we can't do this.  Doing it
> > > without adding many extra special cases would require some thinking
> > > but nothing fundamental says you can't have anonymous pages in the
> > > active list.
> >
> > Right.
> 
> Except that for - presumably dbench-related ? - reasons
> Linus and Davem seem to be vetoeing this change.

Hmm.  I haven't seen a patch for it, and I haven't seen the change being
vetoed by Linus and Davem.  So I'd have to have more context to comment.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
