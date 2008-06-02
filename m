From: Johannes Weiner <hannes@saeurebad.de>
Subject: Re: [PATCH -mm 08/14] bootmem: clean up alloc_bootmem_core
References: <20080530194220.286976884@saeurebad.de>
	<20080530194738.789921715@saeurebad.de>
	<20080602210058.B2E2.E1E9C6FF@jp.fujitsu.com>
Date: Mon, 02 Jun 2008 15:57:44 +0200
In-Reply-To: <20080602210058.B2E2.E1E9C6FF@jp.fujitsu.com> (Yasunori Goto's
	message of "Mon, 02 Jun 2008 21:34:02 +0900")
Message-ID: <87hcccrlbb.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Yinghai Lu <yhlu.kernel@gmail.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Yasunori Goto <y-goto@jp.fujitsu.com> writes:

> Hello.
>
>> +		/*
>> +		 * Reserve the area now:
>> +		 */
>> +		for (i = PFN_DOWN(new_start) + merge; i < PFN_UP(new_end); i++)
>> +			if (test_and_set_bit(i, bdata->node_bootmem_map))
>> +				BUG();
>> +
>> +		region = phys_to_virt(bdata->node_boot_start + new_start);
>> +		memset(region, 0, size);
>> +		return region;
>
> bdata->last_success doesn't seem to be updated in alloc_bootmem_core(),
> it is updated in only __free().
> Is it intended? If not, it should be updated, I suppose....

Yeah, I forgot that.  See my reply to `bootmem: respect goal more
likely'.

Thanks for reviewing!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
