Message-ID: <46A854C7.4060908@gmail.com>
Date: Thu, 26 Jul 2007 10:01:11 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com> <200707260839.51407.bhlope@mweb.co.za> <46A845BB.9080503@gmail.com> <200707260908.02781.bhlope@mweb.co.za>
In-Reply-To: <200707260908.02781.bhlope@mweb.co.za>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bongani Hlope <bhlope@mweb.co.za>
Cc: Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/26/2007 09:08 AM, Bongani Hlope wrote:

> On Thursday 26 July 2007 08:56:59 Rene Herman wrote:

>> Great. Now concentrate on the "swpd" column, as it's the only thing 
>> relevant here. The fact that an updatedb run fills/replaces caches is 
>> completely and utterly unsurprising and not something swap-prefetch
>> helps with. The only thing it does is bring back stuff from _swap_.
> 
> ;)
> 
> I have 2Gb of RAM and I never ever touched swap on all my work loads. I
> was just showing the behavior of updatedb on my desktop. I have never
> even looked at the swap-prefetch patch (for obvious reasons).

I see... thanks for the report :)

> I think people should also look at their /proc/sys/vm/overcommit_ratio

In the sense that current stuff might be evicted earlier with no or little 
overcommit?

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
