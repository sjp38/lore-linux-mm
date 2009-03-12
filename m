Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BAD536B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 04:01:08 -0400 (EDT)
Date: Thu, 12 Mar 2009 15:59:52 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Memory usage per memory zone
Message-ID: <20090312075952.GA19331@localhost>
References: <e2dc2c680903110341g6c9644b8j87ce3b364807e37f@mail.gmail.com> <20090311114353.GA759@localhost> <e2dc2c680903110451m3cfa35d9s7a9fd942bcee39eb@mail.gmail.com> <20090311121123.GA7656@localhost> <e2dc2c680903110516v2c66d4a4h6a422cffceb12e2@mail.gmail.com> <20090311122611.GA8804@localhost> <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2dc2c680903120053w37968c1cy556812cef63f0896@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: jack marrow <jackmarrow2@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Mar 12, 2009 at 09:53:27AM +0200, jack marrow wrote:
> > Can you paste /proc/vmstat, /proc/meminfo, /proc/zoneinfo and
> > /proc/slabinfo? Thank you.
> 
> Sure, but I don't know if it will help.
> 
> The oom info was from in the night, the rest is from now. I have no zoneinfo.
> 
> http://pastebin.com/m67409bc0

Thank you! So you are running a pretty old kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
