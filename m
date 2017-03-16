Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 869526B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:01:56 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id l37so8890649wrc.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:01:56 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d2si6992003wrc.143.2017.03.16.08.01.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 08:01:55 -0700 (PDT)
Date: Thu, 16 Mar 2017 16:01:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MAP_POPULATE vs. MADV_HUGEPAGES
Message-ID: <20170316150153.GK30501@dhcp22.suse.cz>
References: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
 <20170316123449.GE30508@dhcp22.suse.cz>
 <4e1011d9-aef3-5cd7-1424-b81aa79128cb@scylladb.com>
 <20170316144832.GJ30501@dhcp22.suse.cz>
 <53e8bb71-5bf2-2690-f605-aa4d5d50eb90@scylladb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53e8bb71-5bf2-2690-f605-aa4d5d50eb90@scylladb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@scylladb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 16-03-17 16:56:34, Avi Kivity wrote:
> On 03/16/2017 04:48 PM, Michal Hocko wrote:
> >On Thu 16-03-17 15:26:54, Avi Kivity wrote:
[...]
> >>>What is the THP defrag mode
> >>>(/sys/kernel/mm/transparent_hugepage/defrag)?
> >>The default (always).
> >the default has changed since then because the THP faul latencies were
> >just too large. Currently we only allow madvised VMAs to go stall and
> >even then we try hard to back off sooner rather than later. See
> >444eb2a449ef ("mm: thp: set THP defrag by default to madvise and add a
> >stall-free defrag option") merged in 4.4
> 
> I see, thanks.  So the 4.4 behavior is better mostly due to not trying so
> hard.

Please note there were many other patches in the compaction code as
well.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
