Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id KAA13666
	for <linux-mm@kvack.org>; Sat, 12 Oct 2002 10:26:45 -0700 (PDT)
Message-ID: <3DA85B54.3E0A122F@digeo.com>
Date: Sat, 12 Oct 2002 10:26:44 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: 2.5.42-mm2
References: <3DA7C3A5.98FCC13E@digeo.com> <20021012182202.A27215@nightmaster.csn.tu-chemnitz.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ingo Oeser wrote:
> 
> Hi Andrew,
> 
> On Fri, Oct 11, 2002 at 11:39:33PM -0700, Andrew Morton wrote:
> > +remove-kiobufs.patch
> >
> >  Remove the kiobuf infrastructure.
> 
> Stupid question: Would you accept a patch that extends
> get_user_pages() to accept an additional "struct scatterlist vector[]"?

It's not really my area Ingo.  But I can wave such a patch about
on the mailing lists, generally get it some review and attention
I guess.

Such nfrastructure would need something which used it, as a proof-of-concept,
testbed, etc...
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
