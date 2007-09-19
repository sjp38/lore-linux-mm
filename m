Date: Wed, 19 Sep 2007 10:08:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/6] cpuset write dirty map
In-Reply-To: <20070918191405.d9b43470.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709191006160.10862@schroedinger.engr.sgi.com>
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
 <46E742A2.9040006@google.com> <20070914161536.3ec5c533.akpm@linux-foundation.org>
 <46F072A5.8060008@google.com> <20070918191405.d9b43470.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Sep 2007, Andrew Morton wrote:

> How hard would it be to handle the allocation failure in a more friendly
> manner?  Say, if the allocation failed then point mapping->dirty_nodes at
> some global all-ones nodemask, and then special-case that nodemask in the
> freeing code?

Ack. However, the situation dirty_nodes == NULL && inode dirty then means 
that unknown nodes are dirty. If we are later are successful with the 
alloc and we know that the pages are dirty in the mapping then the initial 
dirty_nodes must be all ones. If this is the first page to be dirtied then 
we can start with a dirty_nodes mask of all zeros like now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
