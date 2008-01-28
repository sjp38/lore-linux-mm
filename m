Date: Mon, 28 Jan 2008 16:02:33 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080128150233.GA12021@elte.hu>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123102332.GB21455@csn.ul.ie> <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com> <20080126171803.GA29252@csn.ul.ie> <2f11576a0801262254i55cb2c96q40023aa0e53bffce@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0801262254i55cb2c96q40023aa0e53bffce@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > Can you replace this patch with the patch below instead and try 
> > again please? This is the patch that is actually in git-x86. Out of 
> > curiousity, have you tried the latest mm branch from git-x86?
> 
> to be honest, I didn't understand usage of git, sorry. I learned 
> method of git checkout today and test again (head of git-x86 + your 
> previous patch).

here's a QuickStart:

   http://redhat.com/~mingo/x86.git/README

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
