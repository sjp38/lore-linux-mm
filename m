Date: Fri, 22 Sep 2000 12:20:11 -0400 (EDT)
From: "Mohammad A. Haque" <mhaque@haque.net>
Subject: Re: test9-pre5+t9p2-vmpatch VM deadlock during write-intensive
 workload
In-Reply-To: <20000922151020.A653@post.netlink.se>
Message-ID: <Pine.LNX.4.21.0009221217190.22398-100000@viper.haque.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?Andr=E9_Dahlqvist?= <andre_dahlqvist@post.netlink.se>
Cc: Rik van Riel <riel@conectiva.com.br>, Molnar Ingo <mingo@debella.ikk.sztaki.hu>, "David S. Miller" <davem@redhat.com>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If the process that barfed is swapper then this is the oops that I got
in test9-pre4 w/o any patches.

http://marc.theaimsgroup.com/?l=linux-kernel&m=96936789621245&w=2

On Fri, 22 Sep 2000, Andre Dahlqvist wrote:

> On Fri, Sep 22, 2000 at 07:27:30AM -0300, Rik van Riel wrote:
> 
> > Linus,
> > 
> > could you please include this patch in the next
> > pre patch?
> 
> Rik,
> 
> I just had an oops with this patch applied. I ran into BUG at
> buffer.c:730. The machine was not under load when the oops occured, I
> was just reading e-mail in Mutt. I had to type the oops down by hand,
> but I will provide ksymoops output soon if you need it.
> 

-- 

=====================================================================
Mohammad A. Haque                              http://www.haque.net/ 
                                               mhaque@haque.net

  "Alcohol and calculus don't mix.             Project Lead
   Don't drink and derive." --Unknown          http://wm.themes.org/
                                               batmanppc@themes.org
=====================================================================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
