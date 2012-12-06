Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id CB04F8D0006
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 14:31:43 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id dq11so3347155wgb.26
        for <linux-mm@kvack.org>; Thu, 06 Dec 2012 11:31:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121206173742.GA27297@wolff.to>
References: <20121128145215.d23aeb1b.akpm@linux-foundation.org>
 <20121128235412.GW8218@suse.de> <50B77F84.1030907@leemhuis.info>
 <20121129170512.GI2301@cmpxchg.org> <50B8A8E7.4030108@leemhuis.info>
 <20121201004520.GK2301@cmpxchg.org> <50BC6314.7060106@leemhuis.info>
 <20121203194208.GZ24381@cmpxchg.org> <20121204214210.GB20253@cmpxchg.org>
 <20121205030133.GA17438@wolff.to> <20121206173742.GA27297@wolff.to>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 6 Dec 2012 11:31:21 -0800
Message-ID: <CA+55aFzZsCUk6snrsopWQJQTXLO__G7=SjrGNyK3ePCEtZo7Sw@mail.gmail.com>
Subject: Re: kswapd craziness in 3.7
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno Wolff III <bruno@wolff.to>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Thorsten Leemhuis <fedora@leemhuis.info>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Ellson <john.ellson@comcast.net>

Ok, people seem to be reporting success.

I've applied Johannes' last patch with the new tested-by tags.

Johannes (or anybody else, for that matter), please holler LOUDLY if
you disagreed.. (or if I used the wrong version of the patch, there's
been several, afaik).

                 Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
