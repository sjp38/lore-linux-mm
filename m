Date: Wed, 15 May 2002 09:21:16 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] iowait statistics
Message-ID: <20020515162116.GE27957@holomorphy.com>
References: <200205151514.g4FFEmY13920@Port.imtp.ilyichevsk.odessa.ua> <Pine.LNX.4.44L.0205151310130.9490-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0205151310130.9490-100000@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 May 2002, Denis Vlasenko wrote:
>> I think two patches for same kernel piece at the same time is
>> too many. Go ahead and code this if you want.

On Wed, May 15, 2002 at 01:13:33PM -0300, Rik van Riel wrote:
> OK, here it is.   Changes against yesterday's patch:
> 1) make sure idle time can never go backwards by incrementing
>    the idle time in the timer interrupt too (surely we can
>    take this overhead if we're idle anyway ;))
> 2) get_request_wait also raises nr_iowait_tasks (thanks akpm)
> This patch is against the latest 2.5 kernel from bk and
> pretty much untested. If you have the time, please test
> it and let me know if it works.

I'll take it for a spin on my 8-way HT box; I can remove enough of
the non-compiling device subsystems to get test boots & runs in there.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
