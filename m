Message-ID: <3E31630E.7070601@cyberone.com.au>
Date: Sat, 25 Jan 2003 03:00:14 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.59-mm5
References: <20030123195044.47c51d39.akpm@digeo.com>	<946253340.1043406208@[192.168.100.5]>	<20030124031632.7e28055f.akpm@digeo.com> <15921.11824.472374.112916@laputa.namesys.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Andrew Morton <akpm@digeo.com>, Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov wrote:

>Andrew Morton writes:
>
>[...]
>
> > 
> > In this very common scenario, the only way we'll ever get "lumps" of reads is
> > if some other processes come in and happen to want to read nearby sectors. 
>
>Or if you have read-ahead for meta-data, which is quite useful. Isn't
>read ahead targeting the same problem as this anticipatory scheduling?
>
Finesse vs brute force. A bit of readahead is good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
