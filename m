Date: Fri, 30 May 2008 11:27:52 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 00/25] Vm Pageout Scalability Improvements (V8) -
 continued
Message-ID: <20080530112752.66b6580f@bree.surriel.com>
In-Reply-To: <18496.4309.393775.511382@stoffel.org>
References: <20080529195030.27159.66161.sendpatchset@lts-notebook>
	<20080529131624.60772eb6.akpm@linux-foundation.org>
	<20080529162029.7b942a97@bree.surriel.com>
	<18496.1712.236440.420038@stoffel.org>
	<20080530102917.45cbca64@bree.surriel.com>
	<18496.4309.393775.511382@stoffel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, eric.whitney@hp.com, linux-mm@kvack.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 30 May 2008 10:36:05 -0400
"John Stoffel" <john@stoffel.org> wrote:

> Rik> If you manage to break performance with my patch set somehow,
> Rik> please let me know so I can fix it.  Something like the VM is
> Rik> very subtle and any change is pretty much guaranteed to break
> Rik> something, so I am very interested in feedback.
> 
> What are you using to test/benchmark your changes as you develop this
> patchset?  What would you suggest as a test load to help check
> performance?

Your normal workload.

I am doing some IO throughput, swap throughput and database tests,
however those are probably not representative of what YOU throw at
the VM.

There are no VM benchmarks that cover everything, so what is needed
most at this point is real world exposure.  I cannot promise that
the code is perfect; all I can promise is that I will try to fix
any performance issue that people find.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
