Date: Thu, 31 May 2001 23:53:27 +0200
From: bert hubert <ahu@ds9a.nl>
Subject: Re: http://ds9a.nl/cacheinfo project - please comment & improve
Message-ID: <20010531235326.A14566@home.ds9a.nl>
References: <20010527222020.A25390@home.ds9a.nl> <Pine.LNX.4.21.0105301648290.5231-100000@freak.distro.conectiva> <20010530234806.C8629@home.ds9a.nl> <20010531191729.E754@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010531191729.E754@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Thu, May 31, 2001 at 07:17:30PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 31, 2001 at 07:17:30PM +0200, Ingo Oeser wrote:
> On Wed, May 30, 2001 at 11:48:06PM +0200, bert hubert wrote:
> > Oh, if anybody has ideas on statistics that should be exported, please let
> > me know. On the agenda is a bitmap that describes which pages are actually
> > in the cache.
> 
> You mean sth. like the mincore() syscall?

If you first mmap() the file that would probably work. In dire need of a
manpage though - I'll whip one up and send it to Andries. Probably explains
its relative lack of popularity - I'd never heard of mincore() although it's
been around since BSD4.4 it appears.

Pretty sad that it wastes 7 bits per byte though, but standards conformance
is also useful.

Regards,

bert

-- 
http://www.PowerDNS.com      Versatile DNS Services  
Trilab                       The Technology People   
'SYN! .. SYN|ACK! .. ACK!' - the mating call of the internet
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
