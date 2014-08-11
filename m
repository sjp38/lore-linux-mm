Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id A0E4E6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 13:17:28 -0400 (EDT)
Received: by mail-qc0-f171.google.com with SMTP id r5so1861672qcx.16
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 10:17:28 -0700 (PDT)
Received: from qmta01.emeryville.ca.mail.comcast.net (qmta01.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:16])
        by mx.google.com with ESMTP id x9si22169389qco.17.2014.08.11.10.17.27
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 10:17:27 -0700 (PDT)
Date: Mon, 11 Aug 2014 12:17:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [next:master 9660/12021] mm/vmstat.c:1343:2-5: WARNING: Use
 BUG_ON
In-Reply-To: <alpine.DEB.2.02.1408091329530.2016@localhost6.localdomain6>
Message-ID: <alpine.DEB.2.11.1408111216330.13927@gentwo.org>
References: <53e5eeb3.j/1hw4T//eDPmwb+%fengguang.wu@intel.com> <alpine.DEB.2.02.1408091329530.2016@localhost6.localdomain6>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild@01.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Sat, 9 Aug 2014, Julia Lawall wrote:

> I suspect that using BUG_ON here is not a good idea, because the tested
> called function looks pretty important.  But I have forwarded it on in
> case someone thinks otherwise.

BUG_ON is not a good idea here because the function does essential
allocation and is not just a function that checks for certain error
condition.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
