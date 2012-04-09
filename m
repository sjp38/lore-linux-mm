Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id B28246B004D
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 14:40:51 -0400 (EDT)
Date: Mon, 9 Apr 2012 20:40:48 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: v3.4 BUG: Bad rss-counter state
Message-ID: <20120409184048.GA2478@x4>
References: <20120408113925.GA292@x4>
 <20120409055814.GA292@x4>
 <4F83114E.30106@openvz.org>
 <alpine.LSU.2.00.1204091052590.1430@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1204091052590.1430@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 2012.04.09 at 11:22 -0700, Hugh Dickins wrote:
> On Mon, 9 Apr 2012, Konstantin Khlebnikov wrote:
> > Markus Trippelsdorf wrote:
> > > On 2012.04.08 at 13:39 +0200, Markus Trippelsdorf wrote:
> > > > I've hit the following warning after I've tried to link Firofox's libxul
> > > > with "-flto -lto-partition=none" on my machine with 8GB memory. I've
> 
> I've no notion of what's unusual in that link.

"-lto-partition=none" disables partitioning and streaming of the link
time optimizer.

> > > > killed the process after it used all the memory and 90% of my swap
> 
> Does doing that link push you well into swap on 3.3?

Yes lto1 uses ~12GB of RAM when called with "-lto-partition=none".

> There's a separate mail thread which implicates
> CONFIG_ANDROID_LOW_MEMORY_KILLER (how appropriately named!) in memory
> leaks on 3.4, so please switch that off if you happened to have it on -
> unless you're keen to reproduce these rss-counter messages for us.

No that option is off.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
