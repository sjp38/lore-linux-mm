Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniel Phillips <phillips@arcor.de>
Subject: Re: Time to do something about those loading times
Date: Thu, 29 Aug 2002 20:07:02 +0200
References: <1029399063.1641.65.camel@agnes.fremen.dune>
In-Reply-To: <1029399063.1641.65.camel@agnes.fremen.dune>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <E17kTh8-00034Q-00@starship>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jean Francois Martinez <jfm2@club-internet.fr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 15 August 2002 10:11, Jean Francois Martinez wrote:
> 2) What happens when a code page is discarded?  As I understand it it is
> just discarded and that means next time we will have to look it again
> into the filesystem (and remember that two pages from two different
> libraries will be very far from one another).  Wouldn't it be better to
> copy into swap so next time it will be fetched faster?  The preceeding
> assumes that there is a way to keep swap not overly fragmented.

Pages of code files, and every other kind of file are in fact kept in
cache until memory pressure forces them out.  Linux is pretty good
about that.

-- 
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
