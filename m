From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 2/2] x86_64: Configure stack size
Date: Mon, 19 Nov 2007 21:05:58 +0100
References: <Pine.LNX.4.64.0711121147350.27017@schroedinger.engr.sgi.com> <4741D3C4.4020809@sgi.com>
In-Reply-To: <4741D3C4.4020809@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711192105.58621.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, apw@shadowen.org, Jack Steiner <steiner@sgi.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>     * Modifying a task's CPU affinity:  (29 usages)
> 	set_cpus_allowed(current, cpumask_of_cpu(cpu))

They're usually matched with a set_cpus_allowed(current, oldmask) 
with oldmask being a full arbitrary mask. So eliminating them
would not directly help. 

But I suppose just passing a pointer would work.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
