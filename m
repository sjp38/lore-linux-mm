Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 84ADD6B0073
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 08:05:59 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so15882443pdb.3
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 05:05:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ho6si1211647pbc.172.2015.03.02.05.05.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 05:05:58 -0800 (PST)
Message-ID: <54F45DF4.1040401@oracle.com>
Date: Mon, 02 Mar 2015 07:56:20 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] doc: add information about max_ptes_none
References: <1424986476-6438-1-git-send-email-ebru.akagunduz@gmail.com> <20150227151444.05ce1b31@lwn.net>
In-Reply-To: <20150227151444.05ce1b31@lwn.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, mgorman@suse.de, hughd@google.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, dave@stgolabs.net, aulmcquad@gmail.com, xemul@parallels.com, linux-kernel@vger.kernel.org

On 02/27/2015 05:14 PM, Jonathan Corbet wrote:
>> Value of max_ptes_none can waste cpu time very little, you can
>> ignore it.

This phrase could use rewording I think.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
