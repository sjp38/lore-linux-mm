From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15921.11824.472374.112916@laputa.namesys.com>
Date: Fri, 24 Jan 2003 15:14:40 +0300
Subject: Re: 2.5.59-mm5
In-Reply-To: <20030124031632.7e28055f.akpm@digeo.com>
References: <20030123195044.47c51d39.akpm@digeo.com>
	<946253340.1043406208@[192.168.100.5]>
	<20030124031632.7e28055f.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alex Bligh - linux-kernel <linux-kernel@alex.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

[...]

 > 
 > In this very common scenario, the only way we'll ever get "lumps" of reads is
 > if some other processes come in and happen to want to read nearby sectors. 

Or if you have read-ahead for meta-data, which is quite useful. Isn't
read ahead targeting the same problem as this anticipatory scheduling?

 > In the best case, the size of the lump is proportional to the number of
 > processes which are concurrently trying to read something.  This just doesn't
 > happen enough to be significant or interesting.
 > 
 > But writes are completely different.  There is no dependency between them and
 > at any point in time we know where on-disk a lot of writes will be placed. 
 > We don't know that for reads, which is why we need to twiddle thumbs until the
 > application or filesystem makes up its mind.
 > 

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
