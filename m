Message-ID: <39F74876.29130E9B@norran.net>
Date: Wed, 25 Oct 2000 22:54:14 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: New mm and highmem reminder
References: <Pine.LNX.4.21.0010251601120.943-100000@duckman.distro.conectiva> <m3snpkelat.fsf@linux.local>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Christoph please check with Alt-SysRq-M if you have run out
of memory in a specific zone.

Christoph Rohland wrote:

> MemFree:        182064 kB 
>  - - -
> Inact_dirty:   2793900 kB
> Inact_clean:         0 kB

Rik, notice the imbalance between inactive dirty and
inactive clean...

In this kind of situation when will page_lauder run?

Christoph, can you put a printk in page_launder to
see if it ever runs? (There are a lot of && conditions
to fulfil before kflushd will start)

/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
