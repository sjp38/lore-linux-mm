Date: Mon, 14 Mar 2005 21:59:58 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] mm counter operations through macros
Message-Id: <20050314215958.15544c65.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.58.0503142148510.16812@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0503110422150.19280@schroedinger.engr.sgi.com>
	<20050311182500.GA4185@redhat.com>
	<Pine.LNX.4.58.0503111103200.22240@schroedinger.engr.sgi.com>
	<16946.62799.737502.923025@gargle.gargle.HOWL>
	<Pine.LNX.4.58.0503142103090.16582@schroedinger.engr.sgi.com>
	<20050314214506.050efadf.akpm@osdl.org>
	<Pine.LNX.4.58.0503142148510.16812@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: nikita@clusterfs.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> wrote:
>
> On Mon, 14 Mar 2005, Andrew Morton wrote:
> 
>  > I don't think the MM_COUNTER_T macro adds much, really.  How about this?
> 
>  Then you wont be able to get rid of the counters by
> 
>  #define MM_COUNTER(xx)
> 
>  anymore.

Why would we want to do that?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
