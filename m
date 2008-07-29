Date: Tue, 29 Jul 2008 09:16:50 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: PERF: performance tests with the split LRU VM in -mm
Message-ID: <20080729091650.0ddca3d8@bree.surriel.com>
In-Reply-To: <20080729220012.F192.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080724222510.3bbbbedc@bree.surriel.com>
	<20080729220012.F192.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jul 2008 22:04:16 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> >   TEST 1: dd if=/dev/sda of=/dev/null bs=1M
> > 
> > kernel  speed    swap used
> > 
> > 2.6.26  111MB/s  500kB
> > -mm     110MB/s  59MB     (ouch, system noticably slower)
> > noforce	111MB/s  128kB
> > stream  108MB/s  0        (slight regression, not sure why yet)
> 
> I tried to reproduce it, my ia64 result was
> 
> kernel                   speed        swap used
> 2.6.26-rc8               49.8MB/s     1M
> 2.6.26-rc8-mm1           47.6MB/s     168M
> -mm with above two patch 50.2MB/s     0
> 
> 
> So, I think it isn't regression.

Agreed.  It looked like it, but once I changed the cpuspeed
governor from ondemand to performance, I saw that it had to
be an artifact of something else.

Getting rid of the swap use from a linear IO is the important
part.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
