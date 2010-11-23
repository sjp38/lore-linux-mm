Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B1C5E6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:48:51 -0500 (EST)
Received: by iwn35 with SMTP id 35so135057iwn.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 15:48:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87mxp09mm2.fsf@gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<874obawvlt.fsf@gmail.com>
	<20101122103756.E236.A69D9226@jp.fujitsu.com>
	<87mxp09mm2.fsf@gmail.com>
Date: Wed, 24 Nov 2010 08:48:49 +0900
Message-ID: <AANLkTikhmSZ=oa7ebNqopdV++HgA6wCPnHbHQvwN8eyp@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 10:48 PM, Ben Gamari <bgamari@gmail.com> wrote:
> On Tue, 23 Nov 2010 16:16:55 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>> > On Sun, 21 Nov 2010 23:30:23 +0900, Minchan Kim <minchan.kim@gmail.com> wrote:
>> > >
>> > > Ben, Remain thing is to modify rsync and use
>> > > fadvise(POSIX_FADV_DONTNEED). Could you test it?
>> >
>> > Thanks a ton for the patch. Looks good. Testing as we speak.
>>
> For the record, this was a little premature. As I spoke the kernel was
> building but I still haven't had a chance to take any data. Any
> suggestions for how to determine the effect (or hopefully lack thereof)
> of rsync on the system's working set?
>
>> If possible, can you please post your rsync patch and your testcase
>> (or your rsync option + system memory size info + data size info)?
>>
> Patch coming right up.
>
> The original test case is a backup script for my home directory. rsync
> is invoked with,
>
> rsync --archive --update --progress --delete --delete-excluded
> --exclude-from=~/.backup/exclude --log-file=~/.backup/rsync.log -e ssh
> /home/ben ben@myserver:/mnt/backup/current
>
> My home directory is 120 GB with typical delta sizes of tens of
> megabytes between backups (although sometimes deltas can be gigabytes,
> after which the server has severe interactivity issues). The server is
> unfortunately quite memory constrained with only 1.5GB of memory (old
> inherited hardware). Given the size of my typical deltas, I'm worried
> that even simply walking the directory hierarchy might be enough to push
> out my working set.
>
> Looking at the rsync access pattern with strace it seems that it does
> a very good job of avoid duplicate reads which is good news for these
> patches.

Thanks for the notice. Ben.
FYI, we have a plan to change the policy as you look this thread.
Maybe It would be good than my current policy in the page.

Please recognize it. :)

>
> Cheers,
>
> - Ben
>
>
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
