Message-ID: <3D3C68D9.1020608@us.ibm.com>
Date: Mon, 22 Jul 2002 13:19:37 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [OOPS] 2.5.27 - __free_pages_ok()
References: <1027366468.5170.26.camel@plars.austin.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@austin.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Larson wrote:
> Encountered this first with Linux-2.5.25+rmap and it looks like the
> problem also slipped into 2.5.27.  The same machine boots fine with a
> vanilla 2.5.25 or 2.5.26, but gets this on boot with rmap.  The machine
> is an 8-way PIII-700.

I was hitting the same thing on a Netfinity 8500R/x370.  The problem 
was an old compiler (egcs 2.91-something).  It was triggered by a few 
different things, including kernprof and dcache_rcu.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
