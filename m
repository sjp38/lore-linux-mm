Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA20822
	for <linux-mm@kvack.org>; Tue, 4 Mar 2003 15:21:59 -0800 (PST)
Date: Tue, 4 Mar 2003 15:18:04 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.63-mm2
Message-Id: <20030304151804.259a6473.akpm@digeo.com>
In-Reply-To: <1046819184.12936.100.camel@ibm-b>
References: <20030302180959.3c9c437a.akpm@digeo.com>
	<1046815078.12931.79.camel@ibm-b>
	<20030304140918.4092f09b.akpm@digeo.com>
	<1046819184.12936.100.camel@ibm-b>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Wong <markw@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark Wong <markw@osdl.org> wrote:
>
> Reverting to Linus's 2.5.63 tree produces the same problem for me.  I
> had thought I tried it before, but it turns out I was running 2.5.62. 
> 2.5.62's aic7xxx_old is good for me.

There are no significant differences in that driver between .62 and .63.  So
I am assuming that 2.5.62 works, 2.5.63 doesn't, and that you have not
actually tried 2.5.62's aic7xxx_old in a 2.5.63 tree?

If so, don't bother - it won't make any difference.  Looks like someone broke
something in scsi core which colaterally damaged aic7xxx_old.  I suggest you
feed it into bugme for now.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
