Date: Wed, 3 Oct 2001 14:27:37 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: weird memshared value
Message-ID: <20011003142737.A7266@mikef-linux.matchmail.com>
References: <3BBB7F5F.9040806@brsat.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BBB7F5F.9040806@brsat.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 03, 2001 at 06:13:03PM -0300, Roberto Orenstein wrote:
> Hi Cristoph,
> 
> Guess found a bug in the MemShared value that shows up in /proc/meminfo.
> At least it's pretty weird :)
> 
> After a cp kernel_tree new_tree, together with make bzImage, got the 
> following number:
> 
> MemShared:    4294966488 kB
> 
> My system has only 128MB. P-III, kernel 2.4.9-ac16.
> It doesn't harm, but it's way far from my system mem.
> 

I've just come across this myself.  There is a patch on lkml, look for the
thread ~"4gb memshared, cached bigger than memtotal"...

Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
