Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 198946B00C5
	for <linux-mm@kvack.org>; Sat, 11 Sep 2010 03:29:20 -0400 (EDT)
Date: Sat, 11 Sep 2010 09:29:05 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 08/43] memblock/microblaze: Use new accessors
Message-ID: <20100911072905.GA26366@elte.hu>
References: <1281071724-28740-1-git-send-email-benh@kernel.crashing.org>
 <1281071724-28740-9-git-send-email-benh@kernel.crashing.org>
 <4C5BCD41.3040501@monstr.eu>
 <1281135046.2168.40.camel@pasglop>
 <4C88BD8F.5080208@monstr.eu>
 <20100909115445.GB16157@elte.hu>
 <1284106711.6515.46.camel@pasglop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1284106711.6515.46.camel@pasglop>
Sender: owner-linux-mm@kvack.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michal Simek <monstr@monstr.eu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>
List-ID: <linux-mm.kvack.org>


* Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> > Yep, i asked benh to have a look (see the mail below) but got no 
> > response, as i assumed it had all been taken care of.
> 
> Sorry, I must have been confused... I had pushed out a git branch a 
> while back with those updates and the ARM bits, at least I think I did
> :-) I might have FAILed there. I'll check next week, I'm about to 
> board on a plane right now.

Note, i applied the build error fixes from Yinghai. Please double-check 
things once you have the time.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
