Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id D948038D68
	for <linux-mm@kvack.org>; Wed, 25 Jul 2001 12:49:58 -0300 (EST)
Date: Wed, 25 Jul 2001 12:49:58 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Consistent page aging....
In-Reply-To: <Pine.LNX.4.21.0107250701330.2948-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.33L.0107251249180.20326-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jul 2001, Marcelo Tosatti wrote:
> On 25 Jul 2001, Eric W. Biederman wrote:
> > Marcelo Tosatti <marcelo@conectiva.com.br> writes:
> >
> > > We had to be able to age pages without allocating swap space...
> >
> > I don't see any technical reasons why we can't do this.  Doing it
> > without adding many extra special cases would require some thinking
> > but nothing fundamental says you can't have anonymous pages in the
> > active list.
>
> Right.

Except that for - presumably dbench-related ? - reasons
Linus and Davem seem to be vetoeing this change.

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
