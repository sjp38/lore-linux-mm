Date: Thu, 26 Jan 2006 16:39:38 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [patch 3/9] mempool - Make mempools NUMA aware
In-Reply-To: <43D96A93.9000600@us.ibm.com>
Message-ID: <Pine.LNX.4.62.0601261638210.19078@schroedinger.engr.sgi.com>
References: <20060125161321.647368000@localhost.localdomain>
 <1138233093.27293.1.camel@localhost.localdomain>
 <Pine.LNX.4.62.0601260953200.15128@schroedinger.engr.sgi.com>
 <43D953C4.5020205@us.ibm.com> <Pine.LNX.4.62.0601261511520.18716@schroedinger.engr.sgi.com>
 <43D95A2E.4020002@us.ibm.com> <Pine.LNX.4.62.0601261525570.18810@schroedinger.engr.sgi.com>
 <43D96633.4080900@us.ibm.com> <Pine.LNX.4.62.0601261619030.19029@schroedinger.engr.sgi.com>
 <43D96A93.9000600@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, sri@us.ibm.com, andrea@suse.de, pavel@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Jan 2006, Matthew Dobson wrote:

> That seems a bit beyond the scope of what I'd hoped for this patch series,
> but if an approach like this is believed to be generally useful, it's
> something I'm more than willing to work on...

We need this for other issues as well. f.e. to establish memory allocation 
policies for the page cache, tmpfs and various other needs. Look at 
mempolicy.h which defines a subset of what we need. Currently there is no 
way to specify a policy when invoking the page allocator or slab 
allocator. The policy is implicily fetched from the current task structure 
which is not optimal.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
