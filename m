Message-ID: <47FBC4F8.7030905@cs.helsinki.fi>
Date: Tue, 08 Apr 2008 22:18:16 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [patch 04/18] SLUB: Sort slab cache list and establish maximum
 objects for defrag slabs
References: <20080404230158.365359425@sgi.com>	<20080404230226.577197795@sgi.com> <20080407231113.855e2ba3.akpm@linux-foundation.org>
In-Reply-To: <20080407231113.855e2ba3.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
>> +/* Maximum objects in defragmentable slabs */
>> +static unsigned int max_defrag_slab_objects = 0;
> 
> checkpatch, please (for heavens sake)

Fixed with bunch of other checkpatch errors and warnings. There are some 
80 column warnings remaining still though...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
