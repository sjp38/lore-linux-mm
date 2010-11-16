Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97BAF8D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 08:04:04 -0500 (EST)
Received: from [10.10.7.10] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001484960.msg
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 07:03:59 -0600
Subject: Re: [PATCH][RESEND] nommu: yield CPU periodically while disposing
 large VM
From: "Steven J. Magnani" <steve@digidescorp.com>
Reply-To: steve@digidescorp.com
In-Reply-To: <20101115204703.fc774a17.akpm@linux-foundation.org>
References: <1289507596-17613-1-git-send-email-steve@digidescorp.com>
	 <20101111184059.5744a42f.akpm@linux-foundation.org>
	 <1289831351.2524.15.camel@iscandar.digidescorp.com>
	 <20101115204703.fc774a17.akpm@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 16 Nov 2010 07:03:57 -0600
Message-ID: <1289912637.3449.3.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Ungerer <gerg@snapgear.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2010-11-15 at 20:47 -0800, Andrew Morton wrote:
> On Mon, 15 Nov 2010 08:29:11 -0600 "Steven J. Magnani" <steve@digidescorp.com> wrote:
> 
> > As efficient as schedule() may be, it still scares me to call it on
> > reclaim of every block of memory allocated by a terminating process,
> > particularly on the relatively slow processors that inhabit NOMMU land.
> 
> This is cond_resched(), not schedule()!  cond_resched() is just a few
> instructions, except for the super-rare case where it calls schedule().

The light comes on..._cond_resched() is overloaded. I was looking at the
static version, which calls schedule(). The extern version is much more
lightweight.

I'll respin the patch.

Thanks,
------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
