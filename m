Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 39DF46B0035
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 20:31:33 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so1972545yho.38
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:31:33 -0800 (PST)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id z5si34244414yhd.24.2013.11.25.17.31.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 17:31:32 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f73so3467799yha.35
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 17:31:32 -0800 (PST)
Date: Mon, 25 Nov 2013 17:31:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: user defined OOM policies
In-Reply-To: <20131122001859.GA9510@logfs.org>
Message-ID: <alpine.DEB.2.02.1311251730160.27270@chino.kir.corp.google.com>
References: <20131119131400.GC20655@dhcp22.suse.cz> <20131122001859.GA9510@logfs.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-602059341-1385429491=:27270"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@logfs.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, Glauber Costa <glommer@gmail.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, LKML <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-602059341-1385429491=:27270
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 21 Nov 2013, JA?rn Engel wrote:

> One ancient option I sometime miss was this:
> 	- Kill the biggest process.
> 

That's what both the system and memcg oom killer currently do unless you 
change how "biggest process" is defined with /proc/pid/oom_score_adj.  The 
goal is the kill a single process with the highest rss to avoid having to 
kill many different processes.
--531381512-602059341-1385429491=:27270--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
