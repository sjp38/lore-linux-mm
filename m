Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id C4AD56B03CB
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:17:54 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id c13so62345331lfg.4
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:17:54 -0800 (PST)
Received: from asavdk3.altibox.net (asavdk3.altibox.net. [109.247.116.14])
        by mx.google.com with ESMTPS id c185si15410652lfc.317.2016.12.21.10.17.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:17:53 -0800 (PST)
Date: Wed, 21 Dec 2016 19:17:51 +0100
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC PATCH 04/14] sparc64: load shared id into context register 1
Message-ID: <20161221181751.GE3311@ravnborg.org>
References: <1481913337-9331-1-git-send-email-mike.kravetz@oracle.com>
 <1481913337-9331-5-git-send-email-mike.kravetz@oracle.com>
 <20161217.221442.430708127662119954.davem@davemloft.net>
 <62091365-2797-ed99-847f-7281f4666633@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <62091365-2797-ed99-847f-7281f4666633@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: David Miller <davem@davemloft.net>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, bob.picco@oracle.com, nitin.m.gupta@oracle.com, vijay.ac.kumar@oracle.com, julian.calaby@gmail.com, adam.buchbinder@gmail.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, akpm@linux-foundation.org

Hi Mike.

> Or, perhaps we only enable
> the shared context ID feature on processors which have the ability to work
> around the backwards compatibility feature.

Start out like this, and then see if it is really needed with the older processors.
This should keep the code logic simpler - which is always good for this complicated stuff.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
