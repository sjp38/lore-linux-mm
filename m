Subject: Re: [PATCH] 2.4.20-rmap15a
From: Arjan van de Ven <arjanv@redhat.com>
In-Reply-To: <Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
	<6usmxfys45.fsf@zork.zork.net> <20021203195854.GA6709@zork.net>
	<30200000.1038946087@titus>
	<Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Dec 2002 12:40:05 +0100
Message-Id: <1039002006.1879.0.camel@laptop.fenrus.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-12-03 at 21:56, Rik van Riel wrote:
> On Tue, 3 Dec 2002, Martin J. Bligh wrote:
> 
> > Assuming the extra time is eaten in Sys, not User,
> 
> It's not. It's idle time.  Looks like something very strange
> is going on, vmstat and top output would be nice to have...

I wonder if we miss a run of the tq_disk somewhere.....
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
