Date: Thu, 31 May 2001 19:17:30 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
Message-ID: <20010531191729.E754@nightmaster.csn.tu-chemnitz.de>
References: <20010527222020.A25390@home.ds9a.nl> <Pine.LNX.4.21.0105301648290.5231-100000@freak.distro.conectiva> <20010530234806.C8629@home.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010530234806.C8629@home.ds9a.nl>; from ahu@ds9a.nl on Wed, May 30, 2001 at 11:48:06PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: bert hubert <ahu@ds9a.nl>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 30, 2001 at 11:48:06PM +0200, bert hubert wrote:
> Oh, if anybody has ideas on statistics that should be exported, please let
> me know. On the agenda is a bitmap that describes which pages are actually
> in the cache.

You mean sth. like the mincore() syscall?

Regards

Ingo Oeser
-- 
To the systems programmer,
users and applications serve only to provide a test load.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
