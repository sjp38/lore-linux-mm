Message-ID: <403B6905.2010505@movaris.com>
Date: Tue, 24 Feb 2004 07:08:53 -0800
From: Kirk True <kirk@movaris.com>
MIME-Version: 1.0
Subject: Re: LTP VM test slower under 2.6.3 than 2.4.20
References: <40363778.20900@movaris.com> <20040222231903.5f9ead5c.akpm@osdl.org> <403A2F89.4070405@movaris.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I just upgraded to 2.6.3-mm2 but am still seeing a factor of two speed
slowdown between 2.4.20 and 2.6.3-mm2 for both sequential and random
memory accesses into 1024 MB allocated from malloc.

I'm not trying to whine, I'm looking to explain this behavior and maybe 
be of some help somehow :)

Kirk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
