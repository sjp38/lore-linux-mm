Date: Thu, 26 Oct 2000 17:53:15 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: page fault.
In-Reply-To: <Pine.GSO.4.05.10010261543320.16149-100000@aa.eps.jhu.edu>
Message-ID: <Pine.LNX.4.21.0010261752510.15696-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: afei@jhu.edu
Cc: "M.Jagadish Kumar" <jagadish@rishi.serc.iisc.ernet.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Oct 2000 afei@jhu.edu wrote:
> On Fri, 27 Oct 2000, M.Jagadish Kumar wrote:
> 
> > Is there any way in which i can know when the pagefault occured,
> > i mean at what instruction of my program execution.
> > Does OS provide any support. This would help me to improve my program.

> The way I use is to use oops message and System.map to locate
> the subroutine where the oops occured. To find the exact line
> where the oops occured, you need to either check assemble code
> or use more complicated kernel debug technique. I think Rik
> covered some in his kernel debug slides.

You're confusing issues. A pagefault has NOTHING to do
with an oops...

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
