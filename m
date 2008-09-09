Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m89Hogdj004304
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 13:50:42 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m89HoWMt027190
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 13:50:32 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m89HoQKw031390
	for <linux-mm@kvack.org>; Tue, 9 Sep 2008 13:50:31 -0400
Subject: Re: [RFC] [PATCH -mm] cgroup: limit the amount of dirty file pages
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48C6987D.2050905@gmail.com>
References: <48C6987D.2050905@gmail.com>
Content-Type: text/plain
Date: Tue, 09 Sep 2008 10:49:44 -0700
Message-Id: <1220982584.23386.219.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Paul Menage <menage@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Radford <dradford@bluehost.com>, Marco Innocenti <m.innocenti@cineca.it>, Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao <fernando@oss.ntt.co.jp>, containers@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, Carl Henrik Lunde <chlunde@ping.uio.no>, linux-mm@kvack.org, Divyesh Shah <dpshah@google.com>, Matt Heaton <matt@bluehost.com>, Andrew Morton <akpm@linux-foundation.org>, Naveen Gupta <ngupta@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-09-09 at 17:38 +0200, Andrea Righi wrote:
> It allows to control how much dirty file pages a cgroup can have at any
> given time. This feature is supposed to be strictly connected to a
> generic cgroup IO controller (see below).

So, this functions similarly to our global dirty ratio?  Is it just
intended to keep a cgroup from wedging itself too hard with too many
dirty pages, just like the global ratio?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
