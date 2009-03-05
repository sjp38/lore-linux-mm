Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D1A4C6B00C7
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 09:01:13 -0500 (EST)
Date: Thu, 5 Mar 2009 15:01:25 +0100
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: drop_caches ...
Message-ID: <20090305140125.GD646@ics.muni.cz>
References: <200903041057.34072.M4rkusXXL@web.de> <200903041947.41542.M4rkusXXL@web.de> <20090305004850.GA6045@localhost> <200903051255.35407.M4rkusXXL@web.de> <20090305133603.GA22442@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20090305133603.GA22442@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Markus <M4rkusXXL@web.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Zdenek Kabelac <zkabelac@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 05, 2009 at 09:36:03PM +0800, Wu Fengguang wrote:
> > filesize and "cached" the amount of the file being in cache (why can 
> > this be bigger than the file?!).
> 
>           size = file size in bytes
>         cached = cached pages
> 
> So it's normal that (size > cached).

and one more thing. It seems that at least in the version of filecache I have,
the size and cached are in kB rather than in B.

-- 
Luka1 Hejtmanek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
