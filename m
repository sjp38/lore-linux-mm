Message-ID: <47E91404.7030901@sgi.com>
Date: Tue, 25 Mar 2008 08:02:28 -0700
From: Mike Travis <travis@sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/10] net: remove NR_CPUS arrays in net/core/dev.c
References: <20080325021954.979158000@polaris-admin.engr.sgi.com> <20080325021956.212787000@polaris-admin.engr.sgi.com> <20080325055752.GA4774@martell.zuzino.mipt.ru>
In-Reply-To: <20080325055752.GA4774@martell.zuzino.mipt.ru>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, James Morris <jmorris@namei.org>, Patrick McHardy <kaber@trash.net>
List-ID: <linux-mm.kvack.org>

Alexey Dobriyan wrote:
> On Mon, Mar 24, 2008 at 07:20:02PM -0700, Mike Travis wrote:
>> Remove the fixed size channels[NR_CPUS] array in
>> net/core/dev.c and dynamically allocate array based on
>> nr_cpu_ids.
> 
>> @@ -4362,6 +4362,13 @@ netdev_dma_event(struct dma_client *clie
>>   */
>>  static int __init netdev_dma_register(void)
>>  {
>> +	net_dma.channels = kzalloc(nr_cpu_ids * sizeof(struct net_dma),
>> +								GFP_KERNEL);
>> +	if (unlikely(net_dma.channels)) {
> 
> 		     !net_dma.channels
> 
>> +		printk(KERN_NOTICE
>> +				"netdev_dma: no memory for net_dma.channels\n");
>> +		return -ENOMEM;
>> +	}


Got it, Thanks!  

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
