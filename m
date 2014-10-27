Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id F35E4900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 18:01:44 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id gf13so380239lab.31
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 15:01:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g7si22011422lbs.0.2014.10.27.15.01.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 15:01:43 -0700 (PDT)
Message-ID: <544EC0C5.7050808@suse.cz>
Date: Mon, 27 Oct 2014 23:01:41 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: isolate_freepages_block(): very high intermittent overhead
References: <20141027204003.GB348@x4>
In-Reply-To: <20141027204003.GB348@x4>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>, linux-mm@kvack.org

On 10/27/2014 09:40 PM, Markus Trippelsdorf wrote:
> On my v3.18-rc2 kernel isolate_freepages_block() sometimes shows up very
> high (>20%) in perf top during the configuration phase of software
> builds. It increases build time considerably.
> 
> Unfortunately the issue is not 100% reproducible, because it appears
> only intermittently. And the symptoms vanish after a few minutes.

Does it happen for long enough so you can capture it by perf record -g ?

Vlastimil

> I think the "mm, compaction" series from Vlastimil is to blame, but it's
> hard to be sure when bisection doesn't work.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
