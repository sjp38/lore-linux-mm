Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id D059538D21
	for <linux-mm@kvack.org>; Thu,  9 Aug 2001 17:57:11 -0300 (EST)
Date: Thu, 9 Aug 2001 17:57:10 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swapping for diskless nodes
In-Reply-To: <E15UrUl-0007Rn-00@the-village.bc.nu>
Message-ID: <Pine.LNX.4.33L.0108091756420.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Aug 2001, Alan Cox wrote:

> Ultimately its an insoluble problem, neither SunOS, Solaris or
> NetBSD are infallible, they just never fail for any normal
> situation, and thats good enough for me as a solution

Memory reservations, with reservations on a per-socket
basis, can fix the problem.

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
