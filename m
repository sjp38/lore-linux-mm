Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 999C76B00AC
	for <linux-mm@kvack.org>; Mon, 18 May 2015 08:46:35 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so77707640wic.0
        for <linux-mm@kvack.org>; Mon, 18 May 2015 05:46:35 -0700 (PDT)
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com. [195.75.94.112])
        by mx.google.com with ESMTPS id wn9si17608549wjb.52.2015.05.18.05.46.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Mon, 18 May 2015 05:46:34 -0700 (PDT)
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dahi@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:46:33 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id D8DEA1B0805F
	for <linux-mm@kvack.org>; Mon, 18 May 2015 13:47:18 +0100 (BST)
Received: from d06av12.portsmouth.uk.ibm.com (d06av12.portsmouth.uk.ibm.com [9.149.37.247])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4ICkU1411862406
	for <linux-mm@kvack.org>; Mon, 18 May 2015 12:46:30 GMT
Received: from d06av12.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av12.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4ICkR5w014689
	for <linux-mm@kvack.org>; Mon, 18 May 2015 06:46:30 -0600
Date: Mon, 18 May 2015 14:46:24 +0200
From: David Hildenbrand <dahi@linux.vnet.ibm.com>
Subject: Re: [PATCH v1 00/15] decouple pagefault_disable() from
 preempt_disable()
Message-ID: <20150518144624.3fb3fa46@thinkpad-w530>
In-Reply-To: <alpine.DEB.2.11.1505151620390.4225@nanos>
References: <1431359540-32227-1-git-send-email-dahi@linux.vnet.ibm.com>
	<alpine.DEB.2.11.1505151620390.4225@nanos>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, yang.shi@windriver.com, bigeasy@linutronix.de, benh@kernel.crashing.org, paulus@samba.org, heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com, borntraeger@de.ibm.com, mst@redhat.com, David.Laight@ACULAB.COM, hughd@google.com, hocko@suse.cz, ralf@linux-mips.org, herbert@gondor.apana.org.au, linux@arm.linux.org.uk, airlied@linux.ie, daniel.vetter@intel.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, peterz@infradead.org

> Thanks for picking that up (again)!
> 
> We've pulled the lot into RT and unsurprisingly it works like a charm :)
> 
> Works on !RT as well. 
> 
> Reviewed-and-tested-by: Thomas Gleixner <tglx@linutronix.de>
> 

Thanks a lot Thomas!

@Ingo, @Andrew, nothing changed during the review of this version and Thomas
gave it a review + test.

Any of you willing to pick this up to give it a shot? Or should I resend it with
Thomas' tags added.

Thanks!

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
