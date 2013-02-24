Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E97C26B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 16:25:45 -0500 (EST)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Sun, 24 Feb 2013 14:25:45 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 927FE19D803D
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 14:25:41 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1OLPgLm287580
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 14:25:42 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1OLPfKi003607
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 14:25:41 -0700
Message-ID: <512A8550.2040200@linux.vnet.ibm.com>
Date: Sun, 24 Feb 2013 13:25:36 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: fadvise: fix POSIX_FADV_DONTNEED
References: <1361660281-22165-1-git-send-email-psusi@ubuntu.com> <1361660281-22165-2-git-send-email-psusi@ubuntu.com> <5129710F.6060804@linux.vnet.ibm.com> <51298B0C.2020400@ubuntu.com> <512A5AC4.30808@linux.vnet.ibm.com> <512A7AC4.5000006@ubuntu.com>
In-Reply-To: <512A7AC4.5000006@ubuntu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Phillip Susi <psusi@ubuntu.com>
Cc: linux-mm@kvack.org

On 02/24/2013 12:40 PM, Phillip Susi wrote:
>> > I actually really like the concept behind your patch.  It looks
>> > like very useful functionality.  I'm just saying that I know it
>> > will break _existing_ users.
> I'm not seeing how it will break anything.  Which aspect of the
> current behavior is the app relying on?  If it is the immediate
> removal of clean pages from the cache, then it should not care about
> the new behavior since the pages will still be removed very soon when
> under high cache pressure.

Essentially, they don't want any I/O initiated except that which is
initiated by the app.  If you let the system get in to reclaim, it'll
start doing dirty writeout for pages other than those the app is
interested in.

I'm also not sure how far the "just use O_DIRECT" argument is going to go:

	https://lkml.org/lkml/2007/1/10/233

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
