Date: Thu, 20 Sep 2007 16:08:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] hotplug cpu: move tasks in empty cpusets to parent
Message-Id: <20070920160816.d0a30a69.akpm@linux-foundation.org>
In-Reply-To: <46F037B7.mailxR21ILE48@eag09.americas.sgi.com>
References: <46F037B7.mailxR21ILE48@eag09.americas.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007 15:40:23 -0500
cpw@sgi.com (Cliff Wickman) wrote:

> This patch corrects a situation that occurs when one disables all the cpus
> in a cpuset.

patching file kernel/cpuset.c
Hunk #1 FAILED at 53.
Hunk #2 succeeded at 116 with fuzz 1 (offset 5 lines).
Hunk #3 succeeded at 145 (offset -5 lines).
Hunk #4 FAILED at 544.
Hunk #5 FAILED at 836.
Hunk #6 FAILED at 1125.
Hunk #7 FAILED at 1303.
Hunk #8 FAILED at 2034.
Hunk #9 FAILED at 2102.
Hunk #10 FAILED at 2277.
Hunk #11 FAILED at 2445.
9 out of 11 hunks FAILED -- saving rejects to file kernel/cpuset.c.rej
Failed to apply hotplug-cpu-move-tasks-in-empty-cpusets-to-parent

life sucks a bit at present.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
