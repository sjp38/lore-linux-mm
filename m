Date: Sun, 7 Jan 2001 21:21:45 +0000 (GMT)
From: <davej@suse.de>
Subject: Re: [patch] mm-cleanup-1 (2.4.0)
In-Reply-To: <dnitnrcbji.fsf@magla.iskon.hr>
Message-ID: <Pine.LNX.4.31.0101072120310.5027-100000@athlon.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7 Jan 2001, Zlatko Calusic wrote:

> Anyway, I would than suggest to introduce another /proc entry and call
> it appropriately: max_async_pages. Because that is what we care about,
> anyway. I'll send another patch.

Anton Blanchard already did a patch for this. Sent to the list
on Thu, 7 Dec 2000 16:15:54 +1100 subject:
[PATCH]: sysctl to tune async and sync bdflush triggers

I don't recall seeing any responses to that patch, but it seems
to do exactly what you describe.

regards,

Davej.

-- 
| Dave Jones.        http://www.suse.de/~davej
| SuSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
