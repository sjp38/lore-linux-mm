Date: Thu, 4 Oct 2007 02:06:14 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 3/6] cpuset write throttle
Message-Id: <20071004020614.6abef068.pj@sgi.com>
In-Reply-To: <1191486351.13204.98.camel@twins>
References: <469D3342.3080405@google.com>
	<46E741B1.4030100@google.com>
	<46E7434F.9040506@google.com>
	<20070914161517.5ea3847f.akpm@linux-foundation.org>
	<4702E49D.2030206@google.com>
	<Pine.LNX.4.64.0710031045290.3525@schroedinger.engr.sgi.com>
	<4703FF89.4000601@google.com>
	<Pine.LNX.4.64.0710032055120.4560@schroedinger.engr.sgi.com>
	<1191483450.13204.96.camel@twins>
	<20071004005658.732b96cc.pj@sgi.com>
	<1191485705.5574.1.camel@lappy>
	<1191486351.13204.98.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: clameter@sgi.com, solo@google.com, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter wrote:
> Ok, still need my morning juice. I read tasklist_lock.
> task_lock() should be fine.

Ah - ok.  I was a little surprised you found task_lock to be
unacceptably expensive here ... but didn't know enough to
be sure.  This makes more sense.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
