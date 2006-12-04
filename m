Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB4DkGoT200332
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 13:46:16 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB4DkDhV1863844
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 14:46:13 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB4DkDm9008622
	for <linux-mm@kvack.org>; Mon, 4 Dec 2006 14:46:13 +0100
Date: Mon, 4 Dec 2006 14:46:12 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH/RFC 4/5] vmem shared memory hotplug support
Message-ID: <20061204134612.GH9209@osiris.boeblingen.de.ibm.com>
References: <20061204133132.GB9209@osiris.boeblingen.de.ibm.com> <20061204134027.GF9209@osiris.boeblingen.de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20061204134027.GF9209@osiris.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Carsten Otte <cotte@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> +int remove_shared_memory(unsigned long start, unsigned long size)
> +{
> [...]
> +out:
> +	mutex_unlock(&vmem_mutex);
> +	return ret;
> +}
> [...]
> +int add_shared_memory(unsigned long start, unsigned long size)
> +{
> [...]
> +out:
> +	mutex_unlock(&vmem_mutex);
> +	return ret;
> +}

Just realized that I forgot to flush the TLBs. So it might be a good idea
to add something like global_flush_tlb() at the end of both functions...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
