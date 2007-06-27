Date: Wed, 27 Jun 2007 02:14:08 -0700
From: Andrew Morton <akpm@google.com>
Subject: Re: [RFC 1/7] cpuset write dirty map
Message-Id: <20070627021408.493812fe.akpm@google.com>
In-Reply-To: <Pine.LNX.4.64.0706262017260.24504@schroedinger.engr.sgi.com>
References: <465FB6CF.4090801@google.com>
	<Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>
	<46646A33.6090107@google.com>
	<Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>
	<468023CA.2090401@google.com>
	<Pine.LNX.4.64.0706261216110.20282@schroedinger.engr.sgi.com>
	<20070626152204.b6b4bc3f.akpm@google.com>
	<Pine.LNX.4.64.0706262017260.24504@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007 20:18:36 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 26 Jun 2007, Andrew Morton wrote:
> 
> > Is in my queue somewhere.  Could be that by the time I get to it it will
> > need refreshing (again), we'll see.
> > 
> > One open question is the interaction between these changes and with Peter's
> > per-device-dirty-throttling changes.  They also are in my queue somewhere. 
> > Having a 100:1 coder:reviewer ratio doesn't exactly make for swift
> > progress.
> 
> Hmmmm.. How can we help? I can look at some aspects of Peter's per device 
> throttling.

That can't hurt.

I'm more concerned about all of Mel's code in -mm actually.  I don't recall
anyone doing a full review recently and I'm still not sure that this is the
overall direction in which we wish to go.  Last time I asked this everyone
seemed a bit waffly and non-committal.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
