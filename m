Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 03E796B0005
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 11:59:17 -0500 (EST)
Received: by mail-vc0-f172.google.com with SMTP id l6so212786vcl.31
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 08:59:16 -0800 (PST)
Date: Tue, 5 Feb 2013 08:59:12 -0800
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH 0/3] cleanup memcg controller initialization
Message-ID: <20130205165912.GC4276@mtj.dyndns.org>
References: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360081441-1960-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Feb 05, 2013 at 05:23:58PM +0100, Michal Hocko wrote:
> Hi,
> this is just a small cleanup I promised some time ago[1]. It just moves
> all memcg controller initialization code independant on mem_cgroup into
> subsystem initialization code.
> 
> There are no functional changes.

Looks good to me.  Thanks for doing this. :)

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
