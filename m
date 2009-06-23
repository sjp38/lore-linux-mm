Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F8556B005A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:41:56 -0400 (EDT)
Date: Tue, 23 Jun 2009 10:42:34 -0300
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
	from DCCP
Message-ID: <20090623134234.GE2721@ghostprotocols.net>
References: <20090623023936.GA2721@ghostprotocols.net> <20090622.211927.245716932.davem@davemloft.net> <4A40B69A.2020703@gmail.com> <20090623.040551.37741458.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090623.040551.37741458.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: eric.dumazet@gmail.com, mel@csn.ul.ie, akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

Em Tue, Jun 23, 2009 at 04:05:51AM -0700, David Miller escreveu:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 23 Jun 2009 13:03:54 +0200
> 
> > But it has some bootmem references, it might need more work than
> > just exporting it.
> 
> In that case we should probably just apply the original patch
> for now, and leave this cleanup as a future change.

Full circle! That was my suggestion as well :-)

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
