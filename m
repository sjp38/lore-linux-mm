Date: Fri, 17 Aug 2001 03:35:51 +0200
From: =?iso-8859-1?Q?Jakob_=D8stergaard?= <jakob@unthought.net>
Subject: Re: Swapping for diskless nodes
Message-ID: <20010817033551.A2188@unthought.net>
References: <20010816234639.E755@bug.ucw.cz> <Pine.LNX.4.33L.0108162146120.5646-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.33L.0108162146120.5646-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Thu, Aug 16, 2001 at 09:46:59PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Pavel Machek <pavel@suse.cz>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Bulent Abali <abali@us.ibm.com>, "Dirk W. Steinberg" <dws@dirksteinberg.de>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2001 at 09:46:59PM -0300, Rik van Riel wrote:
> On Thu, 16 Aug 2001, Pavel Machek wrote:
> 
> > I'd call that configuration error. If swap-over-nbd works in all but
> > such cases, its okay with me.
> 
> Agreed. I'm very interested in this case too, I guess we
> should start testing swap-over-nbd and trying to fix things
> as we encounter them...

FYI:  The following has been rock solid for the past two days, using the
machine mainly for emacs/LaTeX/konqueror/...   There's fairly heavy swap
traffic, often  25-40 MB swap is used.

joe@rhinehart:~$ free
             total       used       free     shared    buffers     cached
Mem:         38052      37164        888      20616       2864      16968
-/+ buffers/cache:      17332      20720
Swap:        65528      24788      40740
joe@rhinehart:~$ uname -a
Linux rhinehart 2.2.19pre17 #1 Tue Mar 13 22:37:59 EST 2001 i586 unknown
joe@rhinehart:~$ cat /proc/swaps 
Filename                        Type            Size    Used    Priority
/dev/nbd0                       partition       65528   24728   -2
joe@rhinehart:~$

I'm swapping over a 3Com 374TX pcmcia card in a 100Mbit hub (hooked up to a
switch, connected to the nbd-server machine)

No problems so far - but then again, this is not an NFS-booting BGP4 router  ;)

-- 
................................................................
:   jakob@unthought.net   : And I see the elder races,         :
:.........................: putrid forms of man                :
:   Jakob Ostergaard      : See him rise and claim the earth,  :
:        OZ9ABN           : his downfall is at hand.           :
:.........................:............{Konkhra}...............:
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
