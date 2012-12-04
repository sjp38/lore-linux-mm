Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id D2B456B006C
	for <linux-mm@kvack.org>; Tue,  4 Dec 2012 11:22:43 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so2882699eek.14
        for <linux-mm@kvack.org>; Tue, 04 Dec 2012 08:22:42 -0800 (PST)
Message-ID: <50BE234E.7000603@suse.cz>
Date: Tue, 04 Dec 2012 17:22:38 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <20121128094511.GS8218@suse.de> <50BCC3E3.40804@redhat.com> <20121203191858.GY24381@cmpxchg.org> <50BDBCD9.9060509@redhat.com> <50BDBF1D.60105@suse.cz> <20121204161131.GB24381@cmpxchg.org>
In-Reply-To: <20121204161131.GB24381@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Zdenek Kabelac <zkabelac@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Thorsten Leemhuis <fedora@leemhuis.info>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis.Kletnieks@vt.edu, Bruno Wolff III <bruno@wolff.to>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/04/2012 05:11 PM, Johannes Weiner wrote:
>>>> Any chance you could retry with this patch on top?
>>
>> It does not apply to -next :/. Should I try anything else?
> 
> The COMPACTION_BUILD changed to IS_ENABLED(CONFIG_COMPACTION), below
> is a -next patch.  I hope you don't run into other problems that come
> out of -next craziness, because Linus is kinda waiting for this to be
> resolved to release 3.8.  If you've always tested against -next so far
> and it worked otherwise, don't change the environment now, please.  If
> you just started, it would make more sense to test based on 3.7-rc8.

I reported the issue as soon as it appeared in -next for the first time
on Oct 12. Since then I'm constantly hitting the issue (well, there were
more than one I suppose, but not all of them were fixed by now) until
now. I run only -next...

Going to apply the patch now.

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
