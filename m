Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id A43666B0036
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 09:58:34 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id v10so6875100pde.1
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 06:58:34 -0800 (PST)
Received: from psmtp.com ([74.125.245.196])
        by mx.google.com with SMTP id cj2si10693288pbc.117.2013.11.04.06.58.32
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 06:58:33 -0800 (PST)
Date: Mon, 4 Nov 2013 14:58:28 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: BUG: mm, numa: test segfaults, only when NUMA balancing is on
Message-ID: <20131104145828.GA1218@suse.de>
References: <20131016155429.GP25735@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131016155429.GP25735@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 16, 2013 at 10:54:29AM -0500, Alex Thorlton wrote:
> Hi guys,
> 
> I ran into a bug a week or so ago, that I believe has something to do
> with NUMA balancing, but I'm having a tough time tracking down exactly
> what is causing it.  When running with the following configuration
> options set:
> 

Can you test with patches
cd65718712469ad844467250e8fad20a5838baae..0255d491848032f6c601b6410c3b8ebded3a37b1
applied? They fix some known memory corruption problems, were merged for
3.12 (so alternatively just test 3.12) and have been tagged for -stable.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
