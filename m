Date: Wed, 30 Apr 2003 13:24:07 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [BUG 2.4] Buffers Span Zones
Message-ID: <2387750000.1051734247@flay>
In-Reply-To: <3EB0071B.2020308@google.com>
References: <3EB0071B.2020308@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

> I've found that changing PAGE_OFFSET to reduce the amount of lowmem has been a very good way to exercies the VM.  I've been able to cause all sorts of interesting problems by having ~20M of lowmem and 3G of highmem. I assume that many of these problems would occur on systems with 1G of lowmem and 16-20G of highmem.
> 
> Please CC me on any responses.

It does indeed fall over quite easily on larger machines. Raw IO makes 
it fall over under a light breath of wind (I think it allocates 1024 
buffer_heads up front). 

I've seen about 400MB of buffer_heads before - sucks.

There were some discussion on the archives with Andrew around the middle
of last year - those might prove helpful. We agreed at OLS last year 
to free them immediately after read, but Andrea wanted to keep them around 
after write, and reclaim them lazily (I might have that switched read vs 
write). That's fixed in 2.5 and 2.4-aa I think (though I haven't retested
2.4-aa with raw IO recently). None of it is merged in mailine 2.4 still,
as far as I know, so it still falls over pretty easily.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
