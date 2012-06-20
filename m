Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 863376B0070
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:41:22 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 09:41:21 -0600
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 20624C900AE
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:41:02 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5KFf3h5184584
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 11:41:03 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5KFf2lP031851
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 12:41:02 -0300
Message-ID: <4FE1EF0B.2050109@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2012 10:40:59 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: help converting zcache from sysfs to debugfs?
References: <6b8ff49a-a5aa-4b9b-9425-c9bc7df35a34@default> <4FE1DFDC.1010105@linux.vnet.ibm.com> <83884ff2-1a06-4d9c-a7eb-c53ab0cbb6b1@default>
In-Reply-To: <83884ff2-1a06-4d9c-a7eb-c53ab0cbb6b1@default>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Konrad Wilk <konrad.wilk@oracle.com>, Sasha Levin <levinsasha928@gmail.com>

On 06/20/2012 10:30 AM, Dan Magenheimer wrote:

> But forgive me if I nearly have a heart attack as I
> contemplate another chicken-and-egg scenario trying
> to get debugfs-support-for-atomics upstream before
> zcache code that depends on it.


I don't think this is the same situation as most of our
other chicken and egg situations.  This is a very generic
addition to debugfs (i.e. someone anyone can use, not just
zcache).  Especially as more people use debugfs or convert
some of their sysfs to debufs. In all honesty, I'm surprised
it hasn't been added sooner.

--
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
