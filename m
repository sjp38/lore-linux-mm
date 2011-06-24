Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C659690023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 15:13:38 -0400 (EDT)
Date: Fri, 24 Jun 2011 21:13:34 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
Message-ID: <20110624191334.GA31183@one.firstfloor.org>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com> <m2liwrul1f.fsf@firstfloor.org> <BANLkTimLsnyX6kr6B7uR2SPoHCzuvLzsoQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimLsnyX6kr6B7uR2SPoHCzuvLzsoQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lutomirski <luto@mit.edu>
Cc: Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

On Fri, Jun 24, 2011 at 12:48:20PM -0600, Andrew Lutomirski wrote:
> On Fri, Jun 24, 2011 at 12:44 PM, Andi Kleen <andi@firstfloor.org> wrote:
> > Andrew Lutomirski <luto@mit.edu> writes:
> >
> > [Putting the Intel graphics driver developers in cc.]
> 
> My Sandy Bridge laptop is to blame, the graphics aren't the culprit.  It's this:
> 
>   BIOS-e820: 0000000100000000 - 0000000100600000 (usable)
> 
> The kernel can't handle the tiny bit of memory above 4G.  Mel's
> patches work so far.

Maybe the graphics driver could be still nicer the VM and perhaps
be more aggressive in the callback?

But I failed anyways because the graphics developers run a closed
list. Never mind.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
