Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l26BUiLR308972
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 22:30:49 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l26BHepq114984
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 22:17:40 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l26BEAYA003598
	for <linux-mm@kvack.org>; Tue, 6 Mar 2007 22:14:10 +1100
Message-ID: <45ED4CF7.7030501@linux.vnet.ibm.com>
Date: Tue, 06 Mar 2007 16:43:59 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [ckrm-tech] [PATCH 3/3][RFC] Containers: Pagecache controller
 reclaim
References: <20070305145237.003560000@linux.vnet.ibm.com> > <20070305145311.247699000@linux.vnet.ibm.com>> <1173178212.4998.54.camel@localhost.localdomain>
In-Reply-To: <1173178212.4998.54.camel@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Shane <ibm-main@tpg.com.au>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, balbir@in.ibm.com, xemul@sw.ru, menage@google.com, devel@openvz.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>


Shane wrote:
> Anyone else have trouble fitting this patch ???.
> I see a later version today, but not markedly different from this
> mornings (Aus time). Initially I thought I had the first version, prior
> to Balbir's RSS controller V2 re-write, but apparently not.
> Kernel 2.6.20.1

Hi Shane,

I did post the same patch again today since the previous post
yesterday did not showup on LKML.  I have not changed the version
since it is the same patch.

Next time around i will explicitly mention that this is the same patch
posted again.

> Had to toss it away so I could do some base line testing - I'll redo the
> build and see where the mis-matches are.

Please let me know if so see any problem running the patch.  The
patches are against 2.6.20 only since dependent patches are at that level.

--Vaidy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
