Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: [PATCH][RFC] appling preasure to icache and dcache
Date: Tue, 3 Apr 2001 16:38:41 -0400
References: <3AC9E630.58A4542D@ucla.edu>
In-Reply-To: <3AC9E630.58A4542D@ucla.edu>
MIME-Version: 1.0
Message-Id: <01040316384100.31476@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Redelings I <bredelin@ucla.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 03 April 2001 11:03, Benjamin Redelings I wrote:
> Hi, I'm glad somebody is working on this!  VM-time seems like a pretty
> useful concept.
>
> 	I think you have a bug in your patch here:
>
> +       if (base > pages)       /* If the cache shrunk reset base,  The
> cache
> +               base = pages;    * growing applies preasure as does
> expanding
> +       if (free > old)          * free space - even if later shrinks */
> +               base -= (base>free-old) ? free-old : base;
>
> It looks like you unintentionally commented out two lines of code?
>
> 	I have been successfully running your patch.  But I think it needs
> benchmarks.  At the very least, compile the kernel twice w/o and twice
> w/ your patch and see how it changes the times.  I do not think I will
> have time to do it myself anytime soon unfortunately.
> 	I have a 64Mb RAM machine, and the patch makes the system feel a little
> bit slower when hitting the disk.  BUt that is subjective...
>
> -BenRI
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
