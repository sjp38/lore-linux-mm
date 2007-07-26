Message-ID: <46A845BB.9080503@gmail.com>
Date: Thu, 26 Jul 2007 08:56:59 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: updatedb
References: <367a23780707250830i20a04a60n690e8da5630d39a9@mail.gmail.com> <a491f91d0707251015x75404d9fld7b3382f69112028@mail.gmail.com> <46A81C39.4050009@gmail.com> <200707260839.51407.bhlope@mweb.co.za>
In-Reply-To: <200707260839.51407.bhlope@mweb.co.za>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bongani Hlope <bhlope@mweb.co.za>
Cc: Robert Deaton <false.hopes@gmail.com>, linux-kernel@vger.kernel.org, ck list <ck@vds.kolivas.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/26/2007 08:39 AM, Bongani Hlope wrote:

> On Thursday 26 July 2007 05:59:53 Rene Herman wrote:

>> So what's happening? If you sit down with a copy op "top" in one terminal
>> and updatedb in another, what does it show?

> Just tested that, there's a steady increase in the useage of buff

Great. Now concentrate on the "swpd" column, as it's the only thing relevant 
here. The fact that an updatedb run fills/replaces caches is completely and 
utterly unsurprising and not something swap-prefetch helps with. The only 
thing it does is bring back stuff from _swap_.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
