Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 14A056B0070
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 18:59:26 -0500 (EST)
Received: from /spool/local
	by e3.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 16 Nov 2012 18:59:24 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 36D69C9003C
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 18:59:22 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAGNxMFg279892
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 18:59:22 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAGNxLgS024010
	for <linux-mm@kvack.org>; Fri, 16 Nov 2012 18:59:21 -0500
Message-ID: <50A6D357.3070103@linux.vnet.ibm.com>
Date: Fri, 16 Nov 2012 15:59:19 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Bug 50181] New: Memory usage doubles after more then 20 hours
 of uptime.
References: <bug-50181-27@https.bugzilla.kernel.org/> <20121113140352.4d2db9e8.akpm@linux-foundation.org> <1352988349.6409.4.camel@c2d-desktop.mypicture.info> <20121115141258.8e5cc669.akpm@linux-foundation.org> <1353021103.6409.31.camel@c2d-desktop.mypicture.info> <50A68718.3070002@linux.vnet.ibm.com> <20121116111559.63ec1622.akpm@linux-foundation.org>
In-Reply-To: <20121116111559.63ec1622.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Milos Jakovljevic <sukijaki@gmail.com>, bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

On 11/16/2012 11:15 AM, Andrew Morton wrote:
> On Fri, 16 Nov 2012 10:34:00 -0800
> Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>> Anybody have ideas what to try next or want to poke holes in my
>> statistics? :)
> 
> Maybe resurrect the below patch?  It's probably six years old.  It
> should allow us to find out who allocated those pages.
> 
> Then perhaps we should merge the sucker this time.

I at least got the sucker recompiling.  Not my finest work, but here goes:

http://sr71.net/~dave/linux/leak-20121113/pageowner_for_3.7-rc5.patch

It's not pretty, and probably needs to (at least) get moved over to
debugfs before getting merged, but it does appear to give some
reasonable output.  Figured I'd post it in case anyone else wants to
give it a spin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
