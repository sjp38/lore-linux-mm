Date: Thu, 17 May 2007 11:23:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: RSS controller v2 Test results (lmbench )
Message-Id: <20070517112357.7adc4763.akpm@linux-foundation.org>
In-Reply-To: <464C95D4.7070806@linux.vnet.ibm.com>
References: <464C95D4.7070806@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Pavel Emelianov <xemul@sw.ru>, Paul Menage <menage@google.com>, Kirill Korotaev <dev@sw.ru>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>
List-ID: <linux-mm.kvack.org>

On Thu, 17 May 2007 23:20:12 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> A meaningful container size does not hamper performance. I am in the process
> of getting more results (with varying container sizes). Please let me know
> what you think of the results? Would you like to see different benchmarks/
> tests/configuration results?
> 
> Any feedback, suggestions to move this work forward towards identifying
> and correcting bottlenecks or to help improve it is highly appreciated.

<wakes up>

Memory reclaim tends not to consume much CPU.  Because in steady state it
tends to be the case that the memory reclaim rate (and hopefully the
scanning rate) is equal to the disk IO rate.

Often the most successful way to identify performance problems in there is
by careful code inspection followed by development of exploits.

Is this RSS controller built on Paul's stuff, or is it standalone?

Where do we stand on all of this now anyway?  I was thinking of getting Paul's
changes into -mm soon, see what sort of calamities that brings about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
