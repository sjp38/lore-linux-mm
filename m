Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 2AB5F6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:29:01 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 08:28:59 -0600
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 4D75EC90093
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:20:37 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5KEKaUA145050
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:20:36 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5KEKWAd017938
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:20:32 -0300
Message-ID: <4FE1DC24.6020508@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2012 09:20:20 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: help converting zcache from sysfs to debugfs?
References: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
In-Reply-To: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Sasha Levin <levinsasha928@gmail.com>

On 06/19/2012 07:29 PM, Dan Magenheimer wrote:

> Zcache (in staging) has a large number of read-only counters that
> are primarily of interest to developers.  These counters are currently
> visible from sysfs.  However sysfs is not really appropriate and
> zcache will need to switch to debugfs before it can be promoted
> out of staging.
> 
> For some of the counters, it is critical that they remain accurate so
> an atomic_t must be used.  But AFAICT there is no way for debugfs
> to work with atomic_t.


Yes, there doesn't seem to be an existing interface.

You could add support for it to fs/debugfs/file.c.  It doesn't look too
complicated.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
