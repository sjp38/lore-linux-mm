Message-ID: <47FE7D43.8090406@cs.helsinki.fi>
Date: Thu, 10 Apr 2008 23:49:07 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 05/18] SLUB: Slab defrag core
References: <20080404230158.365359425@sgi.com> <20080404230226.847485429@sgi.com> <20080407231129.3c044ba1.akpm@linux-foundation.org> <Pine.LNX.4.64.0804081401350.31230@schroedinger.engr.sgi.com> <20080408141135.de5a6350.akpm@linux-foundation.org> <Pine.LNX.4.64.0804081416060.31490@schroedinger.engr.sgi.com> <20080408142505.4bfc7a4d.akpm@linux-foundation.org> <Pine.LNX.4.64.0804081441350.31620@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0804101126280.12367@schroedinger.engr.sgi.com> <20080410120042.dc66f4f7.akpm@linux-foundation.org> <Pine.LNX.4.64.0804101332210.13275@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0804101332210.13275@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, mel@skynet.ie, andi@firstfloor.org, npiggin@suse.de, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, 10 Apr 2008, Andrew Morton wrote:
>>> +		static unsigned long global_objects_freed = 0;
>> Wanna buy a patch-checking script?  It's real cheap!

Christoph Lameter wrote:
> Its a strange variable definition that people should pay 
> attention to. = 0 would at least make me notice instead of just assuming
> its just another of those local variables.

I would assume Andrew was referring to the strange variable definition 
and not the unnecessary initialization ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
