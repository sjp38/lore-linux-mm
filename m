Message-ID: <3FB11B93.60701@reactivated.net>
Date: Tue, 11 Nov 2003 17:25:39 +0000
From: Daniel Drake <dan@reactivated.net>
MIME-Version: 1.0
Subject: Re: 2.6.0-test9-mm2
References: <20031104225544.0773904f.akpm@osdl.org>
In-Reply-To: <20031104225544.0773904f.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've been getting a couple of audio skips with 2.6.0-test9-mm2. Haven't heard a 
skip since test4 or so, so I'm assuming this is a result of the IO scheduler tweaks.

Here's how I can produce a skip:
Running X, general usage (e.g. couple of xterms, an emacs, maybe a 
mozilla-thunderbird)
I switch to the first virtual console with Ctrl+Alt+F1. I then switch back to X 
with Alt+F7. As X is redrawing the screen, the audio skips once.
This happens most of the time, but its easier to reproduce when i am compiling 
something, and also when I cycle through the virtual consoles before switching 
back to X.

System:
AMD XP2600+
nForce2 motherboard
512MB RAM
nvidia GeForce4 Ti4800

Audio being played through the intel8x0 alsa module.
I use the nvidia binary graphics driver with X.

XMMS 1.2.8
XFree 4.3.0

If theres any other info I can give, please tell me and I'll do my best to help out.

Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test9/2.6.0-test9-mm2/
> 
> 
> - Various random fixes.  Maybe about half of these are 2.6.0-worthy.
> 
> - Some improvements to the anticipatory IO scheduler and more readahead
>   tweaks should help some of those database benchmarks.
> 
>   The anticipatory scheduler is still a bit behind the deadline scheduler
>   in these random seeky loads - it most likely always will be.
> 
> - "A new driver for the ethernet interface of the NVIDIA nForce chipset,
>   licensed under GPL."
> 
>   Testing of this would be appreciated.  Send any reports to linux-kernel
>   or netdev@oss.sgi.com and Manfred will scoop them up, thanks.
> 
> 
> - I shall be offline for a couple of days.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
