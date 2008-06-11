Date: Wed, 11 Jun 2008 15:36:40 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.26-rc5-mm2: OOM with 1G free swap
In-Reply-To: <20080610232705.3aaf5c06.akpm@linux-foundation.org>
References: <20080611060029.GA5011@martell.zuzino.mipt.ru> <20080610232705.3aaf5c06.akpm@linux-foundation.org>
Message-Id: <20080611153457.7882.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> > vm.overcommit_memory = 0
> > vm.overcommit_ratio = 50
> 
> Well I assume that Rik ran LTP.  Perhaps a merge problem.

at least, I ran LTP last week and its error didn't happend.
I'll investigate more.

Thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
