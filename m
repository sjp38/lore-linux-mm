Date: Mon, 15 Jul 2002 19:55:27 +0300
From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Message-ID: <20020715195527.X28720@mea-ext.zmailer.org>
References: <55160000.1026239746@baldur.austin.ibm.com> <E17U7Gr-0003bX-00@starship> <20020715184016.W28720@mea-ext.zmailer.org> <E17U8kG-0003bx-00@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <E17U8kG-0003bx-00@starship>; from phillips@arcor.de on Mon, Jul 15, 2002 at 06:30:43PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jul 15, 2002 at 06:30:43PM +0200, Daniel Phillips wrote:
> On Monday 15 July 2002 17:40, Matti Aarnio wrote:
> > In register-lacking i386 this  masking is definite punishment..
> 
> Nonsense, the value needs to be loaded into a register anyway
> before being used.

  Think in assembly, what is needed in i386 to mask the pointer ?
  How the pointer is then used ?  How many register you need ?
  What registers can be used for masking arithmetics, and which
  are usable in indexed memory reference address calculation ?

  Linus seems to care about this kind of speed things, and
  at least DaveM does look into gcc generated assembly to
  verify, that used C idioms are compiled correctly and fast.

> Daniel

/Matti Aarnio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
