Date: Wed, 9 Oct 2002 14:00:49 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Hangs in 2.5.41-mm1
Message-ID: <20021009210049.GH12432@holomorphy.com>
References: <1034188573.30975.40.camel@plars> <3DA48EEA.8100302C@digeo.com> <1034195372.30973.64.camel@plars>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1034195372.30973.64.camel@plars>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 09, 2002 at 03:29:28PM -0500, Paul Larson wrote:
> Case 1:
> from ltp, 'runalltests.sh -l /tmp/mm1.log |tee /tmp/mm1.out
> shmt01 (attached test from before)
> shmt01& (repeated 10 times)
> echo 768 > /proc/sys/vm/nr_hugepages
> *hang*
> Case 2:
> cold boot
> echo 768 > /proc/sys/vm/nr_hugepages
> echo 1610612736 > /proc/sys/kernel/shmmax
> shmt01 -s 1610612736&
> shmt01 (immediately after starting the previous command)
> *hang*


You want to check that you still have free hugepages available. It's
passing IPC_CREAT to shmget() so it's trying to create at least double
the number of hugepages you have configured, or 10 times it in case 1.

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
