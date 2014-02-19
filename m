Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ABDD16B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 16:28:00 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so893966pdj.12
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 13:28:00 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id gp2si883367pac.99.2014.02.19.13.27.59
        for <linux-mm@kvack.org>;
        Wed, 19 Feb 2014 13:27:59 -0800 (PST)
Date: Wed, 19 Feb 2014 13:27:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm:prototype for the updated swapoff implementation
Message-Id: <20140219132757.58b61f07bad914b3848275e9@linux-foundation.org>
In-Reply-To: <20140219003522.GA8887@kelleynnn-virtual-machine>
References: <20140219003522.GA8887@kelleynnn-virtual-machine>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kelley Nielsen <kelleynnn@gmail.com>
Cc: riel@surriel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, opw-kernel@googlegroups.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, Hugh Dickins <hughd@google.com>

On Tue, 18 Feb 2014 16:35:22 -0800 Kelley Nielsen <kelleynnn@gmail.com> wrote:

> The function try_to_unuse() is of quadratic complexity, with a lot of
> wasted effort. It unuses swap entries one by one, potentially iterating
> over all the page tables for all the processes in the system for each
> one.
> 
> This new proposed implementation of try_to_unuse simplifies its
> complexity to linear. It iterates over the system's mms once, unusing
> all the affected entries as it walks each set of page tables. It also
> makes similar changes to shmem_unuse.
> 
> Improvement
> 
> swapoff was called on a swap partition containing about 50M of data,
> and calls to the function unuse_pte_range were counted.
> 
> Present implementation....about 22.5M calls.
> Prototype.................about  7.0K   calls.

Do you have situations in which swapoff is taking an unacceptable
amount of time?  If so, please update the changelog to provide full
details on this, with before-and-after timing measurements.

Also, please cc Hugh on swap things.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
