Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id D460D6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 18:13:17 -0400 (EDT)
Received: by qgt47 with SMTP id 47so184370797qgt.2
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 15:13:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p79si23961196qki.119.2015.09.16.15.13.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Sep 2015 15:13:17 -0700 (PDT)
Date: Wed, 16 Sep 2015 15:13:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] slub: Avoid irqoff/on in bulk allocation
Message-Id: <20150916151314.2377c39c5cc48dc71817858c@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org>
References: <alpine.DEB.2.11.1508281443290.11894@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org

On Fri, 28 Aug 2015 14:44:20 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> Use the new function that can do allocation while
> interrupts are disabled.  Avoids irq on/off sequences.
> 

It's going to increase worst-case irq-off times though.  By how much?  Is
it a good tradeoff?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
