From: Brian Jackson <iggy@gentoo.org>
Subject: Re: 2.6.3-rc1-mm1
Date: Tue, 10 Feb 2004 13:45:19 -0600
References: <20040209014035.251b26d1.akpm@osdl.org>
In-Reply-To: <20040209014035.251b26d1.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200402101345.19015.iggy@gentoo.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

kernel bug at mm/slab.c:1107!
invalid operand:0000 [#1]
SMP

(this happened just after the Console: and Memory: lines)
This didn't happen with 2.6.1-mm4 (that's the last -mm I tried). I can try to 
track down where it started later, but this is my firewall, so I have to wait 
till everyone goes to sleep first.

--Iggy

On Monday 09 February 2004 03:40, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.3-rc1/2.6
>.3-rc1-mm1/
>
>


-- 
Home -- http://www.brianandsara.net
Gentoo -- http://gentoo.brianandsara.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
