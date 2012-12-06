Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 4F6456B005D
	for <linux-mm@kvack.org>; Thu,  6 Dec 2012 03:09:09 -0500 (EST)
Message-ID: <50C052A2.90303@leemhuis.info>
Date: Thu, 06 Dec 2012 09:09:06 +0100
From: Thorsten Leemhuis <fedora@leemhuis.info>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <20121127222637.GG2301@cmpxchg.org> <CA+55aFyrNRF8nWyozDPi4O1bdjzO189YAgMukyhTOZ9fwKqOpA@mail.gmail.com> <20121128101359.GT8218@suse.de> <20121128145215.d23aeb1b.akpm@linux-foundation.org> <20121128235412.GW8218@suse.de> <50B77F84.1030907@leemhuis.info> <20121129170512.GI2301@cmpxchg.org> <50B8A8E7.4030108@leemhuis.info> <20121201004520.GK2301@cmpxchg.org> <50BC6314.7060106@leemhuis.info> <20121203194208.GZ24381@cmpxchg.org>
In-Reply-To: <20121203194208.GZ24381@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, John Ellson <john.ellson@comcast.net>

Hi!

Just a quick update

Johannes Weiner wrote on 03.12.2012 20:42:
> On Mon, Dec 03, 2012 at 09:30:12AM +0100, Thorsten Leemhuis wrote:
>
>> BTW, I built that kernel without the patch you mentioned in
>> http://thread.gmane.org/gmane.linux.kernel.mm/90911/focus=91153
>> ("buffer_heads_over_limit can put kswapd into reclaim, but it's ignored
>> [...]) It looked to me like that patch was only meant for debugging. Let
>> me know if that was wrong. Ohh, and I didn't update to a fresher
>> mainline checkout yet to make sure the base for John's testing didn't
>> change.
> 
> Ah, yes, the ApplyPatch is commented out.
> 
> I think we want that upstream as well, but it's not critical.
> [...]

Sorry, it had no "Singed-off-by", so I assumed it was just for debugging.

> Not rebasing sounds reasonable to me to verify the patch.  It might be
> worth testing that the final version that will be 3.8 still works for
> John, however, once that is done.  Just to be sure.

Just to be sure, I yesterday built a rc8 kernel with the patch
referenced above and the one that is not yet merged (these two, to be
precise: http://thread.gmane.org/gmane.linux.kernel.mm/90911/focus=91153
http://thread.gmane.org/gmane.linux.kernel.mm/90911/focus=91300
; all the others patches my kswap test kernels contained earlier were
afaics merged a few days ago) and mentioned it in the Fedora bug report.
John gave them a try and  in
https://bugzilla.redhat.com/show_bug.cgi?id=866988#c65 reported "No
problems so far.  I'll check back again in ~24hours."

CU, Thorsten

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
