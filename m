Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA22397
	for <linux-mm@kvack.org>; Fri, 14 Feb 2003 02:21:57 -0800 (PST)
Date: Fri, 14 Feb 2003 02:22:20 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.60-mm2
Message-Id: <20030214022220.30d0ed69.akpm@digeo.com>
In-Reply-To: <20030214101356.GA17155@codemonkey.org.uk>
References: <20030214013144.2d94a9c5.akpm@digeo.com>
	<20030214093856.GC13845@codemonkey.org.uk>
	<20030214015802.66800166.akpm@digeo.com>
	<20030214101356.GA17155@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Jones <davej@codemonkey.org.uk> wrote:
>
> On Fri, Feb 14, 2003 at 01:58:02AM -0800, Andrew Morton wrote:
> 
>  > > I'm puzzled that you've had NFS stable enough to test these.
>  > This was just writing out a single 400 megabyte file with `dd'.  I didn't try
>  > anything fancier.
> 
> ok. Can you hold off pushing NFS bits to Linus until this gets
> pinned down ? I really don't want to introduce any more variables
> to this, especially when its so hard to pin down to an exact
> replication scenario.

I wouldn't push any NFS bits.  It has a breathing maintainer ;)

I've been mainly looking at the OOM problems, which need MM help.  Got
distracted.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
