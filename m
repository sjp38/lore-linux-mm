From: Alistair John Strachan <s0348365@sms.ed.ac.uk>
Reply-To: s0348365@sms.ed.ac.uk
Subject: Re: 2.6.4-rc2-mm1
Date: Mon, 8 Mar 2004 19:44:01 +0000
MIME-Version: 1.0
Content-Disposition: inline
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200403081944.01964.s0348365@sms.ed.ac.uk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 08 March 2004 06:32, you wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.4-rc2/2.6
>.4-rc2-mm1/
>
>
> - Added Jens's patch which teaches the kernel to use DMA when reading
>   audio from IDE CDROM drives.  These devices tend to be flakey, and we
>   need lots of testing please.
[snip]

This seems to work okay. When ripping a CD, cdparanoia's CPU utilisation
 never peaks beyond 4.0%. Very nice.

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
  445 alistair  18   0  5008 3428 1576 R  4.0  0.7   0:06.25 cdparanoia

No crashes so far. I'll try some bad discs and see how it recovers.

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
