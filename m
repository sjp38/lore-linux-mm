Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f176.google.com (mail-ie0-f176.google.com [209.85.223.176])
	by kanga.kvack.org (Postfix) with ESMTP id C8A566B0071
	for <linux-mm@kvack.org>; Wed,  3 Dec 2014 10:32:03 -0500 (EST)
Received: by mail-ie0-f176.google.com with SMTP id tr6so13394115ieb.7
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 07:32:03 -0800 (PST)
Received: from resqmta-po-04v.sys.comcast.net (resqmta-po-04v.sys.comcast.net. [2001:558:fe16:19:96:114:154:163])
        by mx.google.com with ESMTPS id dz2si16701356igb.11.2014.12.03.07.32.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 03 Dec 2014 07:32:02 -0800 (PST)
Date: Wed, 3 Dec 2014 09:32:00 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Expanding OS noise suppression
In-Reply-To: <547E680F.4080108@amacapital.net>
Message-ID: <alpine.DEB.2.11.1412030931001.2710@gentwo.org>
References: <alpine.DEB.2.11.1411241345250.10694@gentwo.org> <alpine.DEB.2.11.1412011044450.2648@gentwo.org> <547CA12A.6010102@redhat.com> <alpine.DEB.2.11.1412011215240.2903@gentwo.org> <547E680F.4080108@amacapital.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Rik van Riel <riel@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Frederic Weisbecker <fweisbec@gmail.com>

On Tue, 2 Dec 2014, Andy Lutomirski wrote:

> FWIW, context tracking for full nohz is *slow*, so it may reduce noise,
> but it dramatically increases syscall and fault overhead.  This isn't
> really an mm issue, though.

In general though no syscalls are performed in critical latency sensitive
segments and the I/O is done using kernel bypass. So controlling the OS
causing hiccups becomes an important issue.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
