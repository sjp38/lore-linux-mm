Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E97DA6B2B33
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 05:37:56 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id t26so2253943pgu.18
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 02:37:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o19si30580048pfi.261.2018.11.22.02.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Nov 2018 02:37:56 -0800 (PST)
Message-ID: <1542883058.3081.0.camel@suse.de>
Subject: Re: [PATCH v2] mm, hotplug: move init_currently_empty_zone() under
 zone_span_lock protection
From: osalvador <osalvador@suse.de>
Date: Thu, 22 Nov 2018 11:37:38 +0100
In-Reply-To: <20181122101241.7965-1-richard.weiyang@gmail.com>
References: <20181120014822.27968-1-richard.weiyang@gmail.com>
	 <20181122101241.7965-1-richard.weiyang@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, 2018-11-22 at 18:12 +0800, Wei Yang wrote:
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

Thanks ;-)

Reviewed-by: Oscar Salvador <osalvador@suse.de>
