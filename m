Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id BFC3A38C3D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2001 17:58:34 -0300 (EST)
Date: Thu, 9 Aug 2001 17:58:33 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Swapping for diskless nodes
In-Reply-To: <m1snf1tb1q.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0108091758070.1439-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 9 Aug 2001, Eric W. Biederman wrote:

> I don't know about that.  We already can swap over just about
> everything because we can swap over the loopback device.

Last I looked the loopback device could deadlock your
system without you needing to swap over it ;)

Rik
--
IA64: a worthy successor to the i860.

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
