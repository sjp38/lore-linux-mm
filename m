Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id D73406B012A
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 18:18:15 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id p43so3205027wea.24
        for <linux-mm@kvack.org>; Fri, 05 Apr 2013 15:18:14 -0700 (PDT)
Message-ID: <515F4DA3.2000000@suse.cz>
Date: Sat, 06 Apr 2013 00:18:11 +0200
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: Excessive stall times on ext4 in 3.9-rc2
References: <20130402142717.GH32241@suse.de> <20130402150651.GB31577@thunk.org> <20130402151436.GC31577@thunk.org> <20130403101925.GA7341@suse.de>
In-Reply-To: <20130403101925.GA7341@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Theodore Ts'o <tytso@mit.edu>
Cc: linux-ext4@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On 04/03/2013 12:19 PM, Mel Gorman wrote:
> On Tue, Apr 02, 2013 at 11:14:36AM -0400, Theodore Ts'o wrote:
>> On Tue, Apr 02, 2013 at 11:06:51AM -0400, Theodore Ts'o wrote:
>>>
>>> Can you try 3.9-rc4 or later and see if the problem still persists?
>>> There were a number of ext4 issues especially around low memory
>>> performance which weren't resolved until -rc4.
>>
>> Actually, sorry, I took a closer look and I'm not as sure going to
>> -rc4 is going to help (although we did have some ext4 patches to fix a
>> number of bugs that flowed in as late as -rc4).
>>
> 
> I'm running with -rc5 now. I have not noticed much interactivity problems
> as such but the stall detection script reported that mutt stalled for
> 20 seconds opening an inbox and imapd blocked for 59 seconds doing path
> lookups, imaps blocked again for 12 seconds doing an atime update, an RSS
> reader blocked for 3.5 seconds writing a file. etc.
> 
> There has been no reclaim activity in the system yet and 2G is still free
> so it's very unlikely to be a page or slab reclaim problem.

Ok, so now I'm runnning 3.9.0-rc5-next-20130404, it's not that bad, but
it still sucks. Updating a kernel in a VM still results in "Your system
is too SLOW to play this!" by mplayer and frame dropping.

3.5G out of 6G memory used, the rest is I/O cache.

I have 7200RPM disks in my desktop.

-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
