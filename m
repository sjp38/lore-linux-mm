Date: Thu, 3 Aug 2000 11:27:09 -0700 (PDT)
From: <lamont@icopyright.com>
Subject: Re: RFC: design for new VM
In-Reply-To: <20000803191906.B562@metastasis.f00f.org>
Message-ID: <Pine.LNX.4.21.0008031124170.7156-100000@enki.corp.icopyright.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Wedgwood <cw@f00f.org>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

CONFIG_VM_FREEBSD_ME_HARDER would be a nice kernel option to have, if
possible.  Then drop it iff the tweaks are proven over time to work
better.

On Thu, 3 Aug 2000, Chris Wedgwood wrote:
> On Wed, Aug 02, 2000 at 07:08:52PM -0300, Rik van Riel wrote:
> 
>     here is a (rough) draft of the design for the new VM, as
>     discussed at UKUUG and OLS. The design is heavily based
>     on the FreeBSD VM subsystem - a proven design - with some
>     tweaks where we think things can be improved. 
> 
> Can the differences between your system and what FreeBSD has be
> isolated or contained -- I ask this because the FreeBSD VM works
> _very_ well compared to recent linux kernels; if/when the new system
> is implement it would nice to know if performance differences are
> tuning related or because of 'tweaks'.
> 
> 
> 
>   --cw
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
