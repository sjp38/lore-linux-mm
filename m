Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kALCKEhi149132
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 12:20:14 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kALCN4xv2527370
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 12:23:05 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kALCKDhX031548
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 12:20:13 GMT
Date: Tue, 21 Nov 2006 13:19:03 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-ID: <20061121121903.GC8122@osiris.boeblingen.de.ibm.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com> <20061121113708.GB8122@osiris.boeblingen.de.ibm.com> <20061121211937.e25dceb8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061121211937.e25dceb8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, schwidefsky@de.ibm.com
List-ID: <linux-mm.kvack.org>

> > I'd love to go for a generic implementation, but if that is based on
> > sparsemem it doesn't make too much sense on s390.
> 
> 'What type of vmem_map is supported ?' is maybe per-arch decision not generic.
> If people dislikes Flat/Discontig/Sparsemem complication, some clean
> up patch will be posted and discussion will start. If not, nothing will happen.

Ok, I will work on the s390 arch specific patch and post it here. Maybe it's
worth adding a generic vmem_map interface, maybe not. We'll see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
