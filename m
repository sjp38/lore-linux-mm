Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id LAA20254
	for <linux-mm@kvack.org>; Wed, 5 Feb 2003 11:57:59 -0800 (PST)
Date: Wed, 5 Feb 2003 11:57:52 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030205115752.2c416ad4.akpm@digeo.com>
In-Reply-To: <m1r8amzzg6.fsf@frodo.biederman.org>
References: <20030131151501.7273a9bf.akpm@digeo.com>
	<20030202025546.2a29db61.akpm@digeo.com>
	<20030202195908.GD29981@holomorphy.com>
	<20030202124943.30ea43b7.akpm@digeo.com>
	<m1n0ld1jvv.fsf@frodo.biederman.org>
	<20030203132929.40f0d9c0.akpm@digeo.com>
	<m1hebk1u8g.fsf@frodo.biederman.org>
	<20030204055012.GD1599@holomorphy.com>
	<m18yww1q5f.fsf@frodo.biederman.org>
	<162820000.1044342992@[10.10.2.4]>
	<m1znpcz0ag.fsf@frodo.biederman.org>
	<20030204131206.2b6c33fa.akpm@digeo.com>
	<m1r8amzzg6.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: mbligh@aracnet.com, wli@holomorphy.com, davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

ebiederm@xmission.com (Eric W. Biederman) wrote:
>
> Andrew Morton <akpm@digeo.com> writes:
> 
> > ebiederm@xmission.com (Eric W. Biederman) wrote:
> > >
> > > I can't imagine it being useful to guys like oracle without MAP_SHARED
> > > support....
> > 
> > MAP_SHARED is supported.  I haven't tested it much though.
> 
> Given that none of the standard kernel idioms to prevent races in
> this kind of code are present, I would be very surprised if it
> was not racy.
> 
> - inode->i_sem is not taken to protect inode->i_size.

OK, I'll fix that up.

> - After successfully allocating a page, a test is not made to see if
>   another process with the same mapping has allocated the page first.

In this case, add_to_page_cache() in hugetlb_prefault() will return -EEXIST,
and the page which lost the race will be freed again.

Uh, but we don't establish a pte against the page which got there first. 
I'll fix that up too.  Thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
