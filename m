Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7EDDB6B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 09:40:10 -0400 (EDT)
Date: Tue, 28 Sep 2010 08:40:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100928133059.GL8187@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009280838540.6360@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Sep 2010, Mel Gorman wrote:

> Which of these is better or is there an alternative suggestion on how
> this livelock can be avoided?

We need to run some experiments to see what is worse. Lets start by
cutting both the stats threshold and the drift thing in half?

> As a heads up, I'm preparing for exams at the moment and while I'm online, I'm
> not in the position to prototype patches and test them at the moment but can
> review alternative proposals if people have them. I'm also out early next week.

Exams? You are finally graduating?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
