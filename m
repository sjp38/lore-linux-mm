Message-ID: <478BAAD5.1090500@sgi.com>
Date: Mon, 14 Jan 2008 10:32:53 -0800
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/10] x86: Change size of APICIDs from u8 to u16
References: <20080113183453.973425000@sgi.com> <20080113183454.155968000@sgi.com> <Pine.LNX.4.64.0801141908370.24893@fbirervta.pbzchgretzou.qr>
In-Reply-To: <Pine.LNX.4.64.0801141908370.24893@fbirervta.pbzchgretzou.qr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@computergmbh.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@suse.de>, mingo@elte.hu, Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jan Engelhardt wrote:
...
 
>> --- a/arch/x86/mm/srat_64.c
>> +++ b/arch/x86/mm/srat_64.c
>> @@ -384,6 +388,12 @@ int __init acpi_scan_nodes(unsigned long
>> }
>>
>> #ifdef CONFIG_NUMA_EMU
>> +static int fake_node_to_pxm_map[MAX_NUMNODES] __initdata = {
>> +	[0 ... MAX_NUMNODES-1] = PXM_INVAL
>> +};
>> +static unsigned char fake_apicid_to_node[MAX_LOCAL_APIC] __initdata = {
>> +	[0 ... MAX_LOCAL_APIC-1] = NUMA_NO_NODE
>> +};
>> static int __init find_node_by_addr(unsigned long addr)
>> {
>> 	int ret = NUMA_NO_NODE;
> 
> No u8/u16 here?

I see the mistake in the node array.  But AFAICT, pxm is the proximity
between nodes and cannot be expressed as greater than the number of
nodes, yes?  (Or can it be arbitrarily expressed where 32 bits is
necessary?)  I ask this because the real node_to_pxm_map is already
32 bits.

Thanks,
Mike


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
