Date: Wed, 7 May 2003 09:06:32 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: VM limits on AMD64
Message-ID: <20030507160632.GJ19053@holomorphy.com>
References: <Pine.GHP.4.02.10302121019090.19866-100000@alderaan.science-computing.de> <Pine.LNX.4.53.0305071628130.3486@picard.science-computing.de> <20030507155427.GM11820@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030507155427.GM11820@dualathlon.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Oliver Tennert <tennert@science-computing.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 07, 2003 at 04:32:40PM +0200, Oliver Tennert wrote:
>> 1.) The current VM userspace limit for 2.4.x kernels on AMD64 systems in
>> 64bit long mode is 512 G. What is the limit in the current 2.5.x kernels?

On Wed, May 07, 2003 at 05:54:27PM +0200, Andrea Arcangeli wrote:
> 512G, can be changed fairly easily, but there was no need of that yet.
> it's something for 2.7.

I thought it would have been nice to merge the 4-level code, esp. since
there is more than one architecture that wants it.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
