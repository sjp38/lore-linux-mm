Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id UAA17157
	for <linux-mm@kvack.org>; Sun, 29 Sep 2002 20:44:01 -0700 (PDT)
Message-ID: <3D97C880.3C697CD6@digeo.com>
Date: Sun, 29 Sep 2002 20:44:00 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: hugetlbfs-2.5.39-3
References: <20020930003558.GO22942@holomorphy.com> <3D97A052.276A6D59@digeo.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> ..
> huge_pte_alloc() is a sleeping function.

Well we know what's asleep around here, and it's not huge_pte_alloc.
 
> When you plug that one, I'd appreciate it if you could find a way
> of not taking mapping->page_lock inside mm->page_table_lock.  Those
> locks have "no relationship" at present (I think), and it'd be nice
> to keep it that way.

Whatever.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
