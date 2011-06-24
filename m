Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9D85890023D
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 14:48:46 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2541467pwi.14
        for <linux-mm@kvack.org>; Fri, 24 Jun 2011 11:48:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m2liwrul1f.fsf@firstfloor.org>
References: <BANLkTik7ubq9ChR6UEBXOo5D9tn3mMb1Yw@mail.gmail.com> <m2liwrul1f.fsf@firstfloor.org>
From: Andrew Lutomirski <luto@mit.edu>
Date: Fri, 24 Jun 2011 12:48:20 -0600
Message-ID: <BANLkTimLsnyX6kr6B7uR2SPoHCzuvLzsoQ@mail.gmail.com>
Subject: Re: Root-causing kswapd spinning on Sandy Bridge laptops?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, intel-gfx@lists.freedesktop.org

On Fri, Jun 24, 2011 at 12:44 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Andrew Lutomirski <luto@mit.edu> writes:
>
> [Putting the Intel graphics driver developers in cc.]

My Sandy Bridge laptop is to blame, the graphics aren't the culprit.  It's this:

  BIOS-e820: 0000000100000000 - 0000000100600000 (usable)

The kernel can't handle the tiny bit of memory above 4G.  Mel's
patches work so far.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
