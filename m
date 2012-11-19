Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id D3B406B002B
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:44:58 -0500 (EST)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 19 Nov 2012 11:44:55 -0500
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 1BACAC9006F
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:44:54 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAJGirx4283754
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:44:53 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAJGircY011504
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 11:44:53 -0500
Message-ID: <50AA6203.4010407@linux.vnet.ibm.com>
Date: Mon, 19 Nov 2012 08:44:51 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
References: <bug-50181-27@https.bugzilla.kernel.org/> <20121113140352.4d2db9e8.akpm@linux-foundation.org> <1352988349.6409.4.camel@c2d-desktop.mypicture.info> <20121115141258.8e5cc669.akpm@linux-foundation.org> <1353021103.6409.31.camel@c2d-desktop.mypicture.info> <50A68718.3070002@linux.vnet.ibm.com> <20121116111559.63ec1622.akpm@linux-foundation.org> <50A6D357.3070103@linux.vnet.ibm.com>
In-Reply-To: <50A6D357.3070103@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Milos Jakovljevic <sukijaki@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

I managed to reproduce this on a second machine.  The new system ran
basically all weekend doing kernel compiles: no leak.  But, I added some
memory pressure, and made it start allocating a bunch of hugetlbfs
pages.  That made this bug kick in there too.  It's somewhat hard to
tell, but I _think_ the leaking is correlated with compaction activity.

I'm trying a bisect now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
