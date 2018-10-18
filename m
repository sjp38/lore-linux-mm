Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3EADA6B0010
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 09:39:21 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 31-v6so18832151edr.19
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 06:39:21 -0700 (PDT)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id by19-v6si12812389ejb.12.2018.10.18.06.39.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Oct 2018 06:39:19 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 89DAFB888B
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 14:39:19 +0100 (IST)
Date: Thu, 18 Oct 2018 14:39:17 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: get pfn by page_to_pfn() instead of save in
 page->private
Message-ID: <20181018133917.GO5819@techsingularity.net>
References: <20181018130429.37837-1-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20181018130429.37837-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Thu, Oct 18, 2018 at 09:04:29PM +0800, Wei Yang wrote:
> This is not necessary to save the pfn to page->private.
> 
> The pfn could be retrieved by page_to_pfn() directly.
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

page_to_pfn is not free which is why it's cached.

-- 
Mel Gorman
SUSE Labs
