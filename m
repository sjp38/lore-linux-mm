Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 9B88A6B0002
	for <linux-mm@kvack.org>; Sat, 30 Mar 2013 18:07:08 -0400 (EDT)
Received: by mail-ea0-f179.google.com with SMTP id f15so607708eak.24
        for <linux-mm@kvack.org>; Sat, 30 Mar 2013 15:07:06 -0700 (PDT)
Message-ID: <51576207.4090607@suse.cz>
Date: Sat, 30 Mar 2013 23:07:03 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] mm: vmscan: Limit the number of pages kswapd reclaims
 at each priority
References: <1363525456-10448-1-git-send-email-mgorman@suse.de> <1363525456-10448-2-git-send-email-mgorman@suse.de> <20130325090758.GO2154@dhcp22.suse.cz> <51501545.50908@suse.cz> <5154C4B6.102@suse.cz> <20130329082257.GB21227@dhcp22.suse.cz>
In-Reply-To: <20130329082257.GB21227@dhcp22.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, LKML <linux-kernel@vger.kernel.org>

On 03/29/2013 09:22 AM, Michal Hocko wrote:
> On Thu 28-03-13 23:31:18, Jiri Slaby wrote:
>> On 03/25/2013 10:13 AM, Jiri Slaby wrote:
>>> BTW I very pray this will fix also the issue I have when I run ltp tests
>>> (highly I/O intensive, esp. `growfiles') in a VM while playing a movie
>>> on the host resulting in a stuttered playback ;).
>>
>> No, this is still terrible. I was now updating a kernel in a VM and had
>> problems to even move with cursor.
> 
> :/
> 
>> There was still 1.2G used by I/O cache.
> 
> Could you collect /proc/zoneinfo and /proc/vmstat (say in 1 or 2s
> intervals)?

Sure:
http://www.fi.muni.cz/~xslaby/sklad/zoneinfos.tar.xz

I ran the update like 10 s after I started taking snapshots. Mplayer
immediately started complaining:

           ************************************************
           **** Your system is too SLOW to play this!  ****
           ************************************************
etc.

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
