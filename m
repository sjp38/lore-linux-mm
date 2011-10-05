Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 672F29400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 11:29:04 -0400 (EDT)
Received: from /spool/local
	by us.ibm.com with XMail ESMTP
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Wed, 5 Oct 2011 11:24:14 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p95FMqiC088794
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 11:22:53 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p95FMlxq026811
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 11:22:48 -0400
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1317798564.3099.12.camel@edumazet-laptop>
References: <20111001000856.DD623081@kernel>
	 <20111001000900.BD9248B8@kernel>
	 <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
	 <1317798564.3099.12.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Oct 2011 08:22:35 -0700
Message-ID: <1317828155.7842.73.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Wed, 2011-10-05 at 09:09 +0200, Eric Dumazet wrote:
> By the way, "pagesize=4KiB" are just noise if you ask me, thats the
> default PAGE_SIZE. This also breaks old scripts :)

How does it break old scripts?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
