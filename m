Date: Wed, 19 Sep 2001 20:00:44 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: broken VM in 2.4.10-pre9
In-Reply-To: <m1iteegag6.fsf@frodo.biederman.org>
Message-ID: <Pine.LNX.4.33L.0109192000050.19147-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Daniel Phillips <phillips@bonn-fries.net>, Rob Fuller <rfuller@nsisoftware.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 19 Sep 2001, Eric W. Biederman wrote:

> That added to the fact that last time someone ran the numbers linux
> was considerably faster than the BSD for mm type operations when not
> swapping.  And this is the common case.

Optimising the VM for not swapping sounds kind of like
optimising your system for doing empty fork()/exec()/exit()
loops ;)

cheers,

Rik
-- 
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
