Date: Sat, 2 Sep 2000 20:28:43 -0400 (EDT)
From: Byron Stanoszek <gandalf@winds.org>
Subject: Re: Rik van Riel's VM patch
In-Reply-To: <200009030010.RAA01038@gnuppy.monkey.org>
Message-ID: <Pine.LNX.4.21.0009022026140.29638-100000@winds.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Huey <billh@gnuppy.monkey.org>
Cc: John Levon <moz@compsoc.man.ac.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 2 Sep 2000, Bill Huey wrote:

> 
> John,
> 
> > Hi, this is just a short no-statistics testimony that Rik's VM patch
> > to test8-pre1 seems much improved over test7. I have a UP P200 with 40Mb,
> > and previously running KDE2 + mozilla was totally unusable. 
> 
> > With the patch, things run much more smoothly. Interactive feel seems
> > better, and I don't have "swapping holidays" any more.
>  
> > Heavily stressing it by g++ is better as well... 
> > 
> > just a data point,
> > john
> 
> Yes, it kicks butt and it finally (just about) removes the final
> Linux kernel showstopper for recent kernels. ;-)
> 
> I did a GNOME + KDE2 + c++ compile since I've been doing port work
> and I have similar experiences.
> 
> bill

This patch is plain awesome. It really sped up my 586 test machine (very
noticible when compiling XFree86.. which knocked off about a half hour of
compilation time), and there isn't a [noticable] memory leak like in the
old VM system before.

Good work, Rik. Tell us when it's integrated into the kernel. :)

-- 
Byron Stanoszek                         Ph: (330) 644-3059
Systems Programmer                      Fax: (330) 644-8110
Commercial Timesharing Inc.             Email: bstanoszek@comtime.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
