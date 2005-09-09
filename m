Date: Fri, 9 Sep 2005 06:00:15 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 2.6.13] lockless pagecache 7/7
In-Reply-To: <4317F203.7060109@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0509090549110.7332@schroedinger.engr.sgi.com>
References: <4317F071.1070403@yahoo.com.au> <4317F0F9.1080602@yahoo.com.au>
 <4317F136.4040601@yahoo.com.au> <4317F17F.5050306@yahoo.com.au>
 <4317F1A2.8030605@yahoo.com.au> <4317F1BD.8060808@yahoo.com.au>
 <4317F1E2.7030608@yahoo.com.au> <4317F203.7060109@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linux Memory Management <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

For Itanium (and I guess also for ppc64 and sparch64) the performance of 
write_lock/unlock is the same as spin_lock/unlock. There is at least 
one case where concurrent reads would be allowed without this patch. 

Maybe keep the rwlock_t there?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
