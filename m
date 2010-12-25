Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 2A6186B0087
	for <linux-mm@kvack.org>; Sat, 25 Dec 2010 02:38:57 -0500 (EST)
Date: Sat, 25 Dec 2010 15:38:50 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: dirty throttling v5 for 2.6.37-rc7+
Message-ID: <20101225073850.GA1626@localhost>
References: <20101224170418.GA3405@gamma.logic.tuwien.ac.at>
 <20101225030019.GA25383@localhost>
 <20101225052736.GA5649@gamma.logic.tuwien.ac.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101225052736.GA5649@gamma.logic.tuwien.ac.at>
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Norbert,

On Sat, Dec 25, 2010 at 01:27:36PM +0800, Norbert Preining wrote:
> Hi Wu,
> 
> merry christmas to everyone!
> 
> > I just created branch "dirty-throttling-v5" based on today's linux-2.6 head.
> 
> Thanks, pulled, built, rebooting.
> 
> I was running v1 for quite some time, without some planned testing.
> Do you want me to do some more planned testing?

> I am running a sony laptop with debian/sid, doing some heavy disk io
> stuff (svn up on *big* repositories).
 
It's already a test to simply run it in your environment, thanks!
Whether it runs fine or not, they will make valuable feedbacks :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
