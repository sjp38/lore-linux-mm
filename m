Subject: Re: [PATCH] Configurable reclaim batch size
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0709141519230.14894@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Sat, 15 Sep 2007 01:20:02 +0200
Message-Id: <1189812002.5826.31.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-09-14 at 15:23 -0700, Christoph Lameter wrote:
> This patch allows a configuration of the basic reclaim unit for reclaim in 
> vmscan.c. As memory sizes increase so will the frequency of running 
> reclaim. Configuring the reclaim unit higher will reduce the number of 
> times reclaim has to be entered and reduce the number of times that the 
> zone locks have to be taken.

It increases the lock hold times though. Otoh it might work out with the
lock placement.

Do you have any numbers that show this is worthwhile?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
