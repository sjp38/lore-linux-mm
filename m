Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 665506B006E
	for <linux-mm@kvack.org>; Sun, 29 Mar 2015 05:13:21 -0400 (EDT)
Received: by wgbgs4 with SMTP id gs4so49459512wgb.0
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 02:13:20 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id s10si12758906wia.11.2015.03.29.02.13.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Mar 2015 02:13:20 -0700 (PDT)
Received: by wibgn9 with SMTP id gn9so86278057wib.1
        for <linux-mm@kvack.org>; Sun, 29 Mar 2015 02:13:19 -0700 (PDT)
Message-ID: <5517C22D.8040003@plexistor.com>
Date: Sun, 29 Mar 2015 12:13:17 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: Should implementations of ->direct_access be allowed to sleep?
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <1411677218-29146-22-git-send-email-matthew.r.wilcox@intel.com> <20150324185046.GA4994@whiteoak.sf.office.twttr.net> <20150326170918.GO4003@linux.intel.com> <20150326193224.GA28129@dastard> <5517B18A.3050305@plexistor.com>
In-Reply-To: <5517B18A.3050305@plexistor.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, msharbiani@twopensource.com

On 03/29/2015 11:02 AM, Boaz Harrosh wrote:
> On 03/26/2015 09:32 PM, Dave Chinner wrote:
<>
> I think that ->direct_access should not be any different then
> any other block-device access, ie allow to sleep.
> 

BTW: Matthew you yourself have said that after a page-load of memcpy
a user should call sched otherwise bad things will happen to the system
you even commented so on one of my patches when you thought I was
allowing a single memcpy bigger than a page.

So if the user *must* call sched after a call to ->direct_access that
is a "sleep" No?

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
