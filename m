Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 6CF336B0031
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 22:26:31 -0400 (EDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 5 Sep 2013 07:44:49 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id B8AAD1258052
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 07:56:23 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r852SFEJ35913794
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 07:58:15 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r852QP7j027124
	for <linux-mm@kvack.org>; Thu, 5 Sep 2013 07:56:25 +0530
Date: Thu, 5 Sep 2013 10:26:24 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: The scan_unevictable_pages sysctl/node-interface has been
 disabled
Message-ID: <20130905022624.GB8740@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <CANkm-FgvMU-e0uxSvdV1+T5CbEdTCrj=2LVYnVEOALF8myoMxw@mail.gmail.com>
 <20130903230611.GE1412@cmpxchg.org>
 <CANkm-FhyZHXD1bRK-DgunYWYWJHYEAktBCzVkDzVqgXrCQBu-g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CANkm-FhyZHXD1bRK-DgunYWYWJHYEAktBCzVkDzVqgXrCQBu-g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander R <aleromex@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Wed, Sep 04, 2013 at 10:29:41AM +0400, Alexander R wrote:
>Hi,
>yes, I've this message in dmesg output. I don't know what to do with it :)
>What must I to do? Or, what must i've more than this, message?
>

Johannes means if you have a real workload need this interface.

Regards,
Wanpeng Li 

>
>On Wed, Sep 4, 2013 at 3:06 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>     On Tue, Sep 03, 2013 at 11:53:24PM +0400, Alexander R wrote:
>     > [2000266.127978] nr_pdflush_threads exported in /proc is scheduled
>     for
>     > removal
>     > [2000266.128022] sysctl: The scan_unevictable_pages sysctl/node-
>     interface
>     > has been disabled for lack of a legitimate use case. A If you have
>     one,
>     > please send an email to linux-mm@kvack.org.
>
>     Well, do you have one? :-)
>
>     Or is this just leftover in a script somewhere?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
