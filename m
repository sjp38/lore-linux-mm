Received: from firewall.hyperwave.com (firewall.hyperwave.com [129.27.200.34])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA10843
	for <linux-mm@kvack.org>; Thu, 27 Aug 1998 08:08:00 -0400
Date: Thu, 27 Aug 1998 14:07:32 +0200 (MET DST)
Message-Id: <199808271207.OAA15842@hwal02.hyperwave.com>
From: Bernhard Heidegger <bheide@hyperwave.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] 498+ days uptime
In-Reply-To: <87ww7v73zg.fsf@atlas.CARNet.hr>
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

>> "H. Peter Anvin" <hpa@transmeta.com> writes:
>> > 
>> > bdflush yes, but update is not obsolete.
>> > 
>> > It is still needed if you want to make sure data (and metadata)
>> > eventually gets written to disk.
>> > 
>> > Of course, you can run without update, but then don't bother if you
>> > lose file in system crash, even if you edited it and saved it few
>> > hours ago. :)
>> > 
>> > Update is very important if you have lots of RAM in your computer.
>> > 
>> 
>> Oh.  I guess my next question then is "why", as why can't this be done
>> by kflushd as well?
>> 

>> To tell you the truth, I'm not sure why, these days.

>> I thought it was done this way (update running in userspace) so to
>> have control how often buffers get flushed. But, I believe bdflush
>> program had this functionality, and it is long gone (as you correctly
>> noticed).

IMHO, update/bdflush (in user space) calls sys_bdflush regularly. This
function (fs/buffer.c) calls sync_old_buffers() which itself sync_supers
and sync_inodes before it goes through the dirty buffer lust (to write
some dirty buffers); the kflushd only writes some dirty buffers dependent
on the sysctl parameters.
If I'm wrong, please feel free to correct me!

Regards
Bernhard

get my pgp key from a public keyserver (keyID=0x62446355)
-----------------------------------------------------------------------------
Bernhard Heidegger                                       bheide@hyperwave.com
                  Hyperwave Software Research & Development
                       Schloegelgasse 9/1, A-8010 Graz
Voice: ++43/316/820918-25                             Fax: ++43/316/820918-99
-----------------------------------------------------------------------------
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
