Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id AAA29765
	for <linux-mm@kvack.org>; Fri, 28 Feb 2003 00:05:41 -0800 (PST)
Date: Fri, 28 Feb 2003 00:06:34 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Rising io_load results Re: 2.5.63-mm1
Message-Id: <20030228000634.6d23a30c.akpm@digeo.com>
In-Reply-To: <200302280846.04002.baldrick@wanadoo.fr>
References: <20030227025900.1205425a.akpm@digeo.com>
	<20030227160656.40ebeb93.akpm@digeo.com>
	<200302281128.06840.kernel@kolivas.org>
	<200302280846.04002.baldrick@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Duncan Sands <baldrick@wanadoo.fr>
Cc: kernel@kolivas.org, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Duncan Sands <baldrick@wanadoo.fr> wrote:
>
> Hi Con, are you sure this is not the same for 2.5.63?
> I left 2.5.63 running over night (doing nothing but run
> KDE), and in the morning it was swapping heavily.
> About 200MB was swapped out and this did not reduce
> with usage.  According to top, 10% of memory was being
> used by a Konsole with nothing in it (could be a memory
> leak in Konsole).  After half an hour I gave up - it was
> too unusable.  Maybe -mm1 just accentuates a problem
> that is already there in 2.5.63.
> 

Please take a snapshot of /proc/meminfo and /proc/slabinfo
if anything like this happens.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
