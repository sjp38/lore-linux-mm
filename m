Content-Type: text/plain;
  charset="iso-8859-1"
From: Rene Herman <rene.herman@keyaccess.nl>
Subject: Re: VM trouble, both 2.4 and 2.5
Date: Sat, 16 Nov 2002 01:59:02 +0100
References: <02111521422000.00195@7ixe4> <02111601184000.00209@7ixe4> <3DD593A5.9DB99F5@digeo.com>
In-Reply-To: <3DD593A5.9DB99F5@digeo.com>
MIME-Version: 1.0
Message-Id: <02111601590201.00209@7ixe4>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, Con Kolivas <contest@kolivas.net>
List-ID: <linux-mm.kvack.org>

On Saturday 16 November 2002 01:39, Andrew Morton wrote:

> heh.  That mount(8) thing really sucks.  Especially if you
> spend time helping folk out with ext3 problems.
>
> Maybe we should fix it...

Not before I get the chance to laugh at someone *else* being confused by it, 
I hope...

> > Does this bit mean the report was still somewhat useful (for fixing
> > either ext3 or the overcommit accounting) though, or was it already
> > well-known?
>
> Very useful thanks, no it's not well known.  Or at least, it wasn't.

Thanks, makes me feel much better :-)

> Well.  What the heck am I going to do about it?  I guess change the
> overcommit logic to look at page_states.nr_mapped or something.  Or
> maybe take a look at fixing ext3.

Do note that I haven't actually a clue what I'm talking about, but given that 
lack, the latter does sound better. It would seem to make sense to have those 
pages show up in the pagecache, regardless of any ability to work around them 
not doing so elsewhere?

Rene.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
