Date: Thu, 3 Aug 2000 13:01:56 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: RFC: design for new VM
In-Reply-To: <20000803191906.B562@metastasis.f00f.org>
Message-ID: <Pine.LNX.4.21.0008031243070.24022-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>, Matthew Dillon <dillon@apollo.backplane.com>
List-ID: <linux-mm.kvack.org>

On Thu, 3 Aug 2000, Chris Wedgwood wrote:
> On Wed, Aug 02, 2000 at 07:08:52PM -0300, Rik van Riel wrote:
> 
>     here is a (rough) draft of the design for the new VM, as
>     discussed at UKUUG and OLS. The design is heavily based
>     on the FreeBSD VM subsystem - a proven design - with some
>     tweaks where we think things can be improved. 
> 
> Can the differences between your system and what FreeBSD has be
> isolated or contained

You're right, the differences between FreeBSD VM and the new
Linux VM should be clearly indicated.

> I ask this because the FreeBSD VM works _very_ well compared to
> recent linux kernels; if/when the new system is implement it
> would nice to know if performance differences are tuning related
> or because of 'tweaks'.

Indeed. The amount of documentation (books? nah..) on VM
is so sparse that it would be good to have both systems
properly documented. That would fill a void in CS theory
and documentation that was painfully there while I was
trying to find useful information to help with the design
of the new Linux VM...

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
