Date: Thu, 18 May 2000 14:49:18 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH: Possible solution to VM problems (take 2)
Message-ID: <20000518144918.C5672@redhat.com>
References: <20000518125921.A1570@gondor.com> <Pine.LNX.4.21.0005181038230.14198-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0005181038230.14198-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, May 18, 2000 at 10:41:05AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Jan Niehusmann <jan@gondor.com>, Craig Kulesa <ckulesa@loke.as.arizona.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, May 18, 2000 at 10:41:05AM -0300, Rik van Riel wrote:
> 
> I think I have this mostly figured out. I'll work on
> making some small improvements over Quintela's patch
> that will make the system behave decently in this
> situation too.

Good, because apart from the write performance, Juan's patch seems to
work really well for the stress tests I've thrown at it so far.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
