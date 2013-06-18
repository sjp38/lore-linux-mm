Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 865DC6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:23:39 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 18 Jun 2013 11:23:38 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id E1D9B38C8059
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:23:34 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5IFNZ4G244994
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:23:35 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5IFPTP5003141
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 09:25:29 -0600
Date: Tue, 18 Jun 2013 08:23:02 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: vmstat kthreads
Message-ID: <20130618152302.GA10702@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: ghaskins@londonstockexchange.com, niv@us.ibm.com, kravetz@us.ibm.com

Hello!

I have been digging around the vmstat kthreads a bit, and it appears to
me that there is no reason to run a given CPU's vmstat kthread unless
that CPU spends some time executing in the kernel.  If correct, this
observation indicates that one way to safely reduce OS jitter due to the
vmstat kthreads is to prevent them from executing on a given CPU if that
CPU has been executing in usermode since the last time that this CPU's
vmstat kthread executed.

Does this seem like a sensible course of action, or did I miss something
when I went through the code?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
