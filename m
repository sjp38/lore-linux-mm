From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Allow outside read access to a tasks memory policy
Date: Wed, 19 Oct 2005 15:34:29 +0200
References: <Pine.LNX.4.62.0510181126280.8305@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510181126280.8305@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510191534.29538.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tuesday 18 October 2005 20:30, Christoph Lameter wrote:
> Currently access to the memory policy of a task from outside of a task is
> not possible since there are no locking conventions. A task must always be
> able to access its memory policy without the necessity to take a lock in
> order to allow alloc_pages to operate efficiently.

While you could probably make it work for vma policy, it's impossible or hard 
to do the same thing for process policy, which is strictly thread local.

>> Access to the tasks memory policy from the outside is likely going to be
> needed for page migration. In case of an ECC failure or a memory unplug
> operation, new memory needs to be allocated for a task following its memory
> policy. However, that operation is done from outside of the task itself.

Should we perhaps wait with this until the understanding of this is clearer
(e.g. more than "likely")?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
