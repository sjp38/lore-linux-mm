Date: Fri, 23 Aug 2002 09:31:40 +0200
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Re: RAMFS and Swapping
Message-ID: <20020823093140.A634@nightmaster.csn.tu-chemnitz.de>
References: <Pine.OSF.4.10.10208212232070.7953-100000@moon.cdotd.ernet.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.OSF.4.10.10208212232070.7953-100000@moon.cdotd.ernet.in>; from linux1@cdotd.ernet.in on Wed, Aug 21, 2002 at 10:39:26PM +0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Atm account <linux1@cdotd.ernet.in>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 21, 2002 at 10:39:26PM +0500, Atm account wrote:
>    I have  a  simple doubt regarding use Of RAMFS.In which cases should i
> use ramfs/shmfs/tmpfs?
> 
>   If  i create  a RAMFS  on  "RAM" and  run binaries from RAMFS
> created.Would the pages would be swapped to swap device or not.Whether
> the physical pages allocated to the RAMFS would be part of page cache or
> not.

Pages in ramfs are not swappable. Pages in tmpfs/shmfs are in RAM
by default and are swapped out if memory gets thight.

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
