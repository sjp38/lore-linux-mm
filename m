Date: Thu, 23 Mar 2006 23:45:15 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH][0/8] (Targeting 2.6.17) Posix memory locking and balanced
 mlock-LRU semantic
In-Reply-To: <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.63.0603232344190.23558@cuia.boston.redhat.com>
References: <bc56f2f0603200535s2b801775m@mail.gmail.com>
 <Pine.LNX.4.64.0603200923560.24138@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Stone Wang <pwstone@gmail.com>, akpm@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 20 Mar 2006, Christoph Lameter wrote:

> The result of not scanning mlocked pages will be that mmapped files will 
> not be updated unless either the process terminates or msync() is called.

That's ok.  Light swapping on a system with non-mlocked
mmapped pages has the same result, since we won't scan
mapped pages most of the time...

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
