From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Subject: Re: 2.6.0-test9-mm2
Date: Wed, 5 Nov 2003 17:02:00 +0000
References: <20031104225544.0773904f.akpm@osdl.org>
In-Reply-To: <20031104225544.0773904f.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200311051702.00372.s0348365@sms.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@oss.sgi.com
List-ID: <linux-mm.kvack.org>

On Wednesday 05 November 2003 06:55, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.0-test9/2
>.6.0-test9-mm2/
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

I tried the force driver on my nForce2 machine and although it mostly works 
(DHCP works, I can receive mail over the interface, etc..) it doesn't seem to 
handle really bulky loads. For example, I'm running an FTP server on the 
machine (proftpd), and although FTP navigation works just fine, transferring 
large files just causes the transfer to hang indefinitely.

Removing the driver and using NVIDIA's proprietary driver allows me to 
transfer via FTP properly.

-- 
Cheers,
Alistair.

personal:   alistair()devzero!co!uk
university: s0348365()sms!ed!ac!uk
student:    CS/AI Undergraduate
contact:    7/10 Darroch Court,
            University of Edinburgh.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
