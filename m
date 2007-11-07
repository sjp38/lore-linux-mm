From: Andreas Schwab <schwab@suse.de>
Subject: Re: [patch 14/23] inodes: Support generic defragmentation
References: <20071107011130.382244340@sgi.com>
	<20071107011229.893091119@sgi.com>
	<20071107101748.GC7374@lazybastard.org>
Date: Wed, 07 Nov 2007 11:35:13 +0100
In-Reply-To: <20071107101748.GC7374@lazybastard.org> (=?iso-8859-1?Q?=22J?=
 =?iso-8859-1?Q?=F6rn?= Engel"'s message
	of "Wed\, 7 Nov 2007 11\:17\:48 +0100")
Message-ID: <je8x5aibry.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

Jorn Engel <joern@logfs.org> writes:

> On Tue, 6 November 2007 17:11:44 -0800, Christoph Lameter wrote:
>>  
>> +/*
>> + * Function for filesystems that embedd struct inode into their own
>> + * structures. The offset is the offset of the struct inode in the fs inode.
>> + */
>> +void *fs_get_inodes(struct kmem_cache *s, int nr, void **v,
>> +						unsigned long offset)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < nr; i++)
>> +		v[i] += offset;
>> +
>> +	return get_inodes(s, nr, v);
>> +}
>> +EXPORT_SYMBOL(fs_get_inodes);
>
> The fact that all pointers get changed makes me a bit uneasy:
> 	struct foo_inode v[20];
> 	...
> 	fs_get_inodes(..., v, ...);
> 	...
> 	v[0].foo_field = bar;
> 	
> No warning, but spectacular fireworks.

You'l get a warning that struct foo_inode * is incompatible with void **.

Andreas.

-- 
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstrasse 5, 90409 Nurnberg, Germany
PGP key fingerprint = 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
