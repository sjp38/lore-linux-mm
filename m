Date: Tue, 12 Sep 2000 18:04:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] Re: simple FS application that hangs 2.4-test5, mem mgmt
 problem or FS buffer cache mgmt problem?
In-Reply-To: <200009121926.e8CJQGN28377@trampoline.thunk.org>
Message-ID: <Pine.LNX.4.21.0009121804070.1045-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: tytso@mit.edu
Cc: ying@almaden.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Sep 2000 tytso@mit.edu wrote:

>    Date: Fri, 1 Sep 2000 14:03:51 -0300 (BRST)
>    From: Rik van Riel <riel@conectiva.com.br>
> 
>    [Ted: could you add this problem to the 2.4 jobs list?  thanks]
> 
>    On Fri, 1 Sep 2000, Ying Chen/Almaden/IBM wrote:
> 
>    > I while back I reported some problems with buffer cache and
>    > probably memory mgmt subsystem when I ran high IOPS with SPEC
>    > SFS.
> 
>    > I recently tried the same thing, i.e., running large IOPS SPEC
>    > SFS, against the test6 up kernel. I had no problem if I don't
>    > turn HIGHMEM support on in the kernel. As soon as I turned
>    > HIGHMEM support on (I have 2GB memory in my system), I ran into
>    > the same problem, i.e., I'd get "Out of memory" sort of thing
>    > from various subsystems, like SCSI or IP, and eventually my
>    > kernel hangs.
> 
> What's the currents status on this bug?  Many thanks.

I still have no idea what could cause the bug ... ;(

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
