Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E90F18D0046
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 12:24:36 -0400 (EDT)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p2HGOY3j008242
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 09:24:34 -0700
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by hpaq6.eem.corp.google.com with ESMTP id p2HGM9si002596
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 09:24:33 -0700
Received: by qwb8 with SMTP id 8so2225270qwb.38
        for <linux-mm@kvack.org>; Thu, 17 Mar 2011 09:24:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110317155139.GA16195@infradead.org>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
	<AANLkTimeH-hFiqtALfzyyrHiLz52qQj0gCisaJ-taCdq@mail.gmail.com>
	<20110317155139.GA16195@infradead.org>
Date: Thu, 17 Mar 2011 09:24:28 -0700
Message-ID: <AANLkTikxEQfzFOrc1Kyu+eC8EnTpDfKYHNswLu+0AtZS@mail.gmail.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple approach)
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>

Hi Christoph:

On Thu, Mar 17, 2011 at 8:51 AM, Christoph Hellwig <hch@infradead.org> wrot=
e:
> On Thu, Mar 17, 2011 at 08:46:23AM -0700, Curt Wohlgemuth wrote:
>> But if one of one's goals is to provide some sort of disk isolation base=
d on
>> cgroup parameters, than having at most one stream of write requests
>> effectively neuters the IO scheduler.
>
> If you use any kind of buffered I/O you already fail in that respect.
> Writeback from balance_dirty_page really is just the wort case right now
> with more I/O supposed to be handled by the background threads. =A0So if
> you want to implement isolation properly you need to track the
> originator of the I/O between the copy to the pagecache and actual
> writeback.

Which is indeed part of the patchset I referred to above ("[RFC]
[PATCH 0/6] Provide cgroup isolation for buffered writes",
https://lkml.org/lkml/2011/3/8/332 ).

Thanks,
Curt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
