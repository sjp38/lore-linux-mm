Message-ID: <399AD517.656E4279@ucla.edu>
Date: Wed, 16 Aug 2000 10:53:27 -0700
From: Benjamin Redelings <bredelin@ucla.edu>
MIME-Version: 1.0
Subject: new vm - OK but not THAT great
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,
	I tested Rik's latest, tuned, VM code on my machine at home.  Sorry
this isn't more detailed - I have to do some comparisons later.
	However, I DO notice some problems: when I run netscape and a few other
apps, performance is OK, but when I then run 'tar -xf
linux-2.4.0-pre4.tar' preformance drops.
	Firstly, the page cache gets really big.  A LOT of swap is suddenly
used, like 25 MB where before there was nothing, and running programs
(netscape,gnomehack,the gnome panel) start getting unresponsive due to
swapin.
	Secondly, programs like xfs, which are NOT RUNNING AT ALL, do not get
swapped out as much as vanilla pre7-4.
	So, the page aging code does not appear to be helping as much as it
should.  Swapping seems, in some sense, to not as good as pre7-4...
	Awaiting next tuned version!!

-BenRI
P.S. could this block of code go into the mainstreat kernel w/o the rest
of the code?

> +     /* Reset to 0 when we reach the end of address space */
> +     mm->swap_address = 0;
> +     mm->swap_cnt = 0;
> +
> +out_unlock:
>       vmlist_access_unlock(mm);
>  
>       /* We didn't find anything for the process */
> -     mm->swap_cnt = 0;
> -     mm->swap_address = 0;
>       return 0;
>  }

-- 
"For nature does not give virtue,
 It is an art to become good." - Seneca
Benjamin Redelings I      <><     http://www.bol.ucla.edu/~bredelin
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
