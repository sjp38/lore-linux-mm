Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 774346B0033
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 09:02:39 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id t11so621629lbi.11
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 06:02:37 -0700 (PDT)
Message-ID: <5176866A.2060400@openvz.org>
Date: Tue, 23 Apr 2013 17:02:34 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [question] call mark_page_accessed() in minor fault
References: <20130423122542.GA5638@gmail.com>
In-Reply-To: <20130423122542.GA5638@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-mm@kvack.org, muming.wq@taobao.com

Zheng Liu wrote:
> Hi all,
>
> Recently we meet a performance regression about mmaped page.  When we upgrade
> our product system from 2.6.18 kernel to a latest kernel, such as 2.6.32 kernel,
> we will find that mmaped pages are reclaimed very quickly.  We found that when
> we hit a minor fault mark_page_accessed() is called in 2.6.18 kernel, but in
> 2.6.32 kernel we don't call mark_page_accesed().  This means that mmaped pages
> in 2.6.18 kernel are activated and moved into active list.  While in 2.6.32
> kernel mmaped pages are still kept in inactive list.
>
> So my question is why we call mark_page_accessed() in 2.6.18 kernel, but don't
> call it in 2.6.32 kernel.  Has any reason here?

Behavior was changed in commit
v2.6.28-6130-gbf3f3bc "mm: don't mark_page_accessed in fault path"

Please see also commits
v3.2-4876-g34dbc67 "vmscan: promote shared file mapped pages" and
v3.2-4877-gc909e99 "vmscan: activate executable pages after first usage".
Probably they can solve some of your problems.

>
> Thanks in advance,
> 						- Zheng
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
