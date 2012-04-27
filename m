Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E04576B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 23:32:21 -0400 (EDT)
Date: Thu, 26 Apr 2012 23:32:13 -0400 (EDT)
Message-Id: <20120426.233213.2080676231209264997.davem@davemloft.net>
Subject: Re: Weirdness in __alloc_bootmem_node_high
From: David Miller <davem@davemloft.net>
In-Reply-To: <20120424.030050.767238391336824492.davem@davemloft.net>
References: <20120422.220054.1961736352806510855.davem@davemloft.net>
	<20120424063236.GA23963@merkur.ravnborg.org>
	<20120424.030050.767238391336824492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sam@ravnborg.org
Cc: yinghai@kernel.org, tj@kernel.org, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Tue, 24 Apr 2012 03:00:50 -0400 (EDT)

> From: Sam Ravnborg <sam@ravnborg.org>
> Date: Tue, 24 Apr 2012 08:32:36 +0200
> 
>> On Sun, Apr 22, 2012 at 10:00:54PM -0400, David Miller wrote:
>>> diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
>>> index db4e821..3763302 100644
>>> --- a/arch/sparc/Kconfig
>>> +++ b/arch/sparc/Kconfig
>>> @@ -109,6 +109,9 @@ config NEED_PER_CPU_EMBED_FIRST_CHUNK
>>>  config NEED_PER_CPU_PAGE_FIRST_CHUNK
>>>  	def_bool y if SPARC64
>>>  
>>> +config NO_BOOTMEM
>>> +	def_bool y if SPARC64
>> 
>> mm/Kconfig define NO_BOOTMEM so you can just add a "select NO_BOOTMEM"
>> to SPARC64.
> 
> I was merely following the lead on x86 :-) but yes it should
> probably be a select.

So I merged mainline into sparc-next to get the mm/nobootmem.c fix,
and then added in the sparc64 NO_BOOTMEM conversion.

Just FYI.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
