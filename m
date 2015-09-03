Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1C71B6B0254
	for <linux-mm@kvack.org>; Thu,  3 Sep 2015 15:33:08 -0400 (EDT)
Received: by padfa1 with SMTP id fa1so13063014pad.1
        for <linux-mm@kvack.org>; Thu, 03 Sep 2015 12:33:07 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id fo8si592123pad.223.2015.09.03.12.33.06
        for <linux-mm@kvack.org>;
        Thu, 03 Sep 2015 12:33:07 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use case please?
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
Date: Thu, 03 Sep 2015 12:33:06 -0700
In-Reply-To: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
	(James Hartshorn's message of "Mon, 24 Aug 2015 20:12:24 +0000")
Message-ID: <878u8n47t9.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hartshorn <jhartshorn@connexity.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

James Hartshorn <jhartshorn@connexity.com> writes:

Your report seems to completely lack any detail, like
kernel version, description of the problem, etc.

> I've been struggling with transparent hugepage performance issues, and
> can't seem to find anyone who actually uses it intentionally.
> Virtually every database that runs on linux however recommends
> disabling it or setting it to madvise. I'm referring to:

Please see if you can reproduce your problem on a recent mainline
kernel (there were a lot of compaction improvements recently,
which can be a source of issues with THP)

If yes then please submit a test case and it can be investigated.

If no then update.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
