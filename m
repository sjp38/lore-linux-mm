Subject: Re: [RFC][PATCH 8/8] RSS controller support reclamation
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20061109193636.21437.11778.sendpatchset@balbir.in.ibm.com>
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com>
	 <20061109193636.21437.11778.sendpatchset@balbir.in.ibm.com>
Content-Type: text/plain
Date: Thu, 09 Nov 2006 20:45:43 +0100
Message-Id: <1163101543.3138.528.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, ckrm-tech@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 2006-11-10 at 01:06 +0530, Balbir Singh wrote:
> 
> Reclaim memory as we hit the max_shares limit. The code for reclamation
> is inspired from Dave Hansen's challenged memory controller and from the
> shrink_all_memory() code


Hmm.. I seem to remember that all previous RSS rlimit attempts actually
fell flat on their face because of the reclaim-on-rss-overflow behavior;
in the shared page / cached page (equally important!) case, it means
process A (or container A) suddenly penalizes process B (or container B)
by making B have pagecache misses because A was using a low RSS limit.

Unmapping the page makes sense, sure, and even moving then to inactive
lists or whatever that is called in the vm today, but reclaim... that's
expensive...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
