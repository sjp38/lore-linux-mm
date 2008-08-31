Received: by ti-out-0910.google.com with SMTP id j3so877999tid.8
        for <linux-mm@kvack.org>; Sun, 31 Aug 2008 11:37:14 -0700 (PDT)
Date: Sun, 31 Aug 2008 21:36:52 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH] kmemtrace: SLUB hooks for caller-tracking functions.
Message-ID: <20080831183652.GA5220@localhost>
References: <1219600175-5253-1-git-send-email-eduard.munteanu@linux360.ro> <48BAAC3C.4050309@cs.helsinki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48BAAC3C.4050309@cs.helsinki.fi>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, mathieu.desnoyers@polymtl.ca, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, Aug 31, 2008 at 05:35:40PM +0300, Pekka Enberg wrote:
> Eduard - Gabriel Munteanu wrote:
>> This patch adds kmemtrace hooks for __kmalloc_track_caller() and
>> __kmalloc_node_track_caller(). Currently, they set the call site pointer
>> to the value recieved as a parameter. (This could change if we implement
>> stack trace exporting in kmemtrace.)
>> Signed-off-by: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
>
> Applied. I had to do some manual tweaking, so can you please double-check 
> the result:
>
> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=b9f1ecc6428f0ba391845b2ac7df8618da287e4f
>
> Thanks!

Looks fine to me. However, you can now remove the casts to unsigned long
from 'caller', i.e. "s/(unsigned long) caller/caller/g"

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
