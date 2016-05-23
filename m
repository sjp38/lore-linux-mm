Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 683056B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 09:11:48 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 81so27820021wms.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 06:11:48 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz298.laposte.net. [178.22.154.198])
        by mx.google.com with ESMTPS id gx6si44099641wjb.76.2016.05.23.06.11.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 06:11:45 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout010 (Postfix) with ESMTP id 5A1B445B093
	for <linux-mm@kvack.org>; Mon, 23 May 2016 15:11:45 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.prosodie [10.128.63.2])
	by lpn-prd-vrout010 (Postfix) with ESMTP id 5482345B077
	for <linux-mm@kvack.org>; Mon, 23 May 2016 15:11:45 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id 3003B366A57
	for <linux-mm@kvack.org>; Mon, 23 May 2016 15:11:45 +0200 (CEST)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz> <573593EE.6010502@free.fr>
 <5735A3DE.9030100@laposte.net> <20160513120042.GK20141@dhcp22.suse.cz>
 <5735CAE5.5010104@laposte.net> <20160513145101.GS20141@dhcp22.suse.cz>
 <5735EE7A.4010600@laposte.net> <20160513164113.6317c491@lxorguk.ukuu.org.uk>
From: Sebastian Frias <sf84@laposte.net>
Message-ID: <57430190.1080401@laposte.net>
Date: Mon, 23 May 2016 15:11:44 +0200
MIME-Version: 1.0
In-Reply-To: <20160513164113.6317c491@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Alan,

On 05/13/2016 05:41 PM, One Thousand Gnomes wrote:
>> My understanding is that there was a time when there was no overcommit at all.
>> If that's the case, understanding why overcommit was introduced would be helpful.
> 
> Linux always had overcommit.
> 
> The origin of overcommit is virtual memory for the most part. In a
> classic swapping system without VM the meaning of brk() and thus malloc()
> is that it allocates memory (or swap). Likewise this is true of fork()
> and stack extension.
> 
> In a virtual memory system these allocate _address space_. It does not
> become populated except by page faulting, copy on write and the like. It
> turns out that for most use cases on a virtual memory system we get huge
> amounts of page sharing or untouched space.
> 
> Historically Linux did guess based overcommit and I added no overcommit
> support way back when, along with 'anything is allowed' support for
> certain HPC use cases.
> 
> The beancounter patches combined with this made the entire setup
> completely robust but the beancounters never hit upstream although years
> later they became part of the basis of the cgroups.
> 
> You can sort of set a current Linux up for definitely no overcommit using
> cgroups and no overcommit settings. It works for most stuff although last
> I checked most graphics drivers were terminally broken (and not just to
> no overcommit but to the point you can remote DoS Linux boxes with a
> suitably constructed web page and chrome browser)
> 
> Alan
> 

Thanks for your comment, it certainly provides more clues and provided some history about the "overcommit" setting.
I will see if we can do what we want with cgroups.

Best regards,

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
