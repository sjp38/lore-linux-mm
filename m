Date: Thu, 7 Jun 2001 14:38:15 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] Reap dead swap cache earlier v2
In-Reply-To: <l0313031cb745811cfc17@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106071435580.1156-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 7 Jun 2001, Jonathan Morton wrote:

> >As suggested by Linus, I've cleaned the reapswap code to be contained
> >inside an inline function. (yes, the if statement is really ugly)
> 
> I can't seem to find the patch which adds this behaviour to the background
> scanning.  

I've just sent Linus a patch to free swap cache pages at the time we free
the last pte. (requested by himself)

With it applied we should get the old behaviour back again. 

I can put it on my webpage if you wish. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
