Date: Sat, 11 Feb 2006 21:37:07 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Get rid of scan_control
Message-Id: <20060211213707.0ef39582.akpm@osdl.org>
In-Reply-To: <20060211211437.0633dfdb.akpm@osdl.org>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
	<20060211045355.GA3318@dmt.cnet>
	<20060211013255.20832152.akpm@osdl.org>
	<20060211014649.7cb3b9e2.akpm@osdl.org>
	<43EEAC93.3000803@yahoo.com.au>
	<Pine.LNX.4.62.0602111941480.25758@schroedinger.engr.sgi.com>
	<43EEB4DA.6030501@yahoo.com.au>
	<Pine.LNX.4.62.0602112036350.25872@schroedinger.engr.sgi.com>
	<43EEC136.5060609@yahoo.com.au>
	<20060211211437.0633dfdb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nickpiggin@yahoo.com.au, clameter@engr.sgi.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
>  Returning nr_reclaimed up and down the stack makes sense too - I'll try that.

wtf does this, in zone_reclaim() do?

		sc.nr_reclaimed = 1;    /* Avoid getting the off node timeout */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
