Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
From: Paul Larson <plars@austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>
References: <Pine.LNX.4.44L.0207221704120.3086-100000@imladris.surriel.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Jul 2002 17:34:32 -0500
Message-Id: <1027377273.5170.37.camel@plars.austin.ibm.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, 2002-07-22 at 15:05, Rik van Riel wrote:
> Now that I think about it, could you try enabling RMAP_DEBUG
> in mm/rmap.c and try triggering this bug again ?
Done, output attached below.

On Mon, 2002-07-22 at 15:19, Dave Hansen wrote:
> I was hitting the same thing on a Netfinity 8500R/x370.  The problem 
> was an old compiler (egcs 2.91-something).  It was triggered by a few 
> different things, including kernprof and dcache_rcu.
Well, it was a redhat box.  Just to be certain, I made sure to use kgcc
and it still hung on boot, but kgcc is egcs-2.91.66 19990314/Linux
(egcs-1.1.2 release).  If it would be helpful, I'll try compiling my
kernel on a debian box tomorrow and booting with that.

Thanks,
Paul Larson

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
