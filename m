Subject: Re: Swapping for diskless nodes
References: <Pine.LNX.4.33L.0108091758070.1439-100000@duckman.distro.conectiva>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 10 Aug 2001 02:11:46 -0600
In-Reply-To: <Pine.LNX.4.33L.0108091758070.1439-100000@duckman.distro.conectiva>
Message-ID: <m1k80ctjul.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@conectiva.com.br> writes:

> On 9 Aug 2001, Eric W. Biederman wrote:
> 
> > I don't know about that.  We already can swap over just about
> > everything because we can swap over the loopback device.
> 
> Last I looked the loopback device could deadlock your
> system without you needing to swap over it ;)

It wouldn't suprise me.  But the fact remains that in 2.4 we allow it.
And if we allw it there is little excuse for doing it wrong.

Actually except for network cases it looks easier to prevent deadlocks
on the swapping path than with the loop back devices.  We can call
aops->prepare_write_out when we place the page in the swap cache
to make certain we aren't over a hole in a file, and there is room in the
filesystem to store the data.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
