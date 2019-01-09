Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3498E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:29:01 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id g188so3875126pgc.22
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:29:01 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b70si14605663pfe.168.2019.01.09.02.28.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:28:58 -0800 (PST)
Date: Wed, 9 Jan 2019 13:28:47 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [bug report] mm, compaction: round-robin the order while
 searching the free lists for a target
Message-ID: <20190109102847.GE1718@kadam>
References: <20190109082733.GA5424@kadam>
 <20190109102546.GS31517@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190109102546.GS31517@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org

On Wed, Jan 09, 2019 at 10:25:46AM +0000, Mel Gorman wrote:
> On Wed, Jan 09, 2019 at 11:27:33AM +0300, Dan Carpenter wrote:
> > Hello Mel Gorman,
> > 
> > The patch 1688e2896de4: "mm, compaction: round-robin the order while
> > searching the free lists for a target" from Jan 8, 2019, leads to the
> > following static checker warning:
> > 
> > 	mm/compaction.c:1252 next_search_order()
> > 	warn: impossible condition '(cc->search_order < 0) => (0-u16max < 0)'
> > 
> 
> Thanks Dan!
> 
> Does the following combination of two patches address it? The two
> patches address separate problems with two patches in the series.
> 

Yes.  Thanks.

regards,
dan carpenter
