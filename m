From: John Bradford <john@grabjohn.com>
Message-Id: <200304221745.h3MHjA8m000202@81-2-122-30.bradfords.org.uk>
Subject: Re: objrmap and vmtruncate
Date: Tue, 22 Apr 2003 18:45:10 +0100 (BST)
In-Reply-To: <182180000.1051028196@[10.10.2.4]> from "Martin J. Bligh" at Apr 22, 2003 09:16:37 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@digeo.com>, Andrea Arcangeli <andrea@suse.de>, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > make almost zero noticeable difference on a 768 MB system - i have a 768
> > MB system. Whether 1MB of extra RAM to a 128 MB system will make more of a
> > difference than a predictable VM - i dont know, it probably depends on the
> > app, but i'd go for more RAM. But it will make a _hell_ of a difference on
> > a 1 TB RAM 64-bit system where the sharing factor explodes. And that's
> > where Linux usage we will be by the time 2.6 based systems go production.

> You obviously have a somewhat different timeline in mind for 2.6 than the
> rest of us ;-)

It's certainly where Linux usage will be before 2.8 is ready.

(and anyway, I'm sure there's a subsystem that we haven't _yet_
re-written during the feature freeze...  :-) )


John.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
