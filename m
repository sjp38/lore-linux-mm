Message-ID: <46D6CEF3.3070701@aitel.hist.no>
Date: Thu, 30 Aug 2007 16:06:43 +0200
From: Helge Hafting <helge.hafting@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: speeding up swapoff
References: <fa.j/pO3mTWDugTdvZ3XNr9XpvgzPQ@ifi.uio.no>	 <fa.ed9fasZXOwVCrbffkPQTX7G3a7g@ifi.uio.no>	 <fa./NZA3biuO1+qW5pW8ybdZMDWcZs@ifi.uio.no> <46D61F48.5090406@shaw.ca>	 <46D6CC35.90207@aitel.hist.no> <1188482815.1131.374.camel@frg-rhel40-em64t-04>
In-Reply-To: <1188482815.1131.374.camel@frg-rhel40-em64t-04>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Xavier Bestel <xavier.bestel@free.fr>
Cc: Robert Hancock <hancockr@shaw.ca>, Daniel Drake <ddrake@brontes3d.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Xavier Bestel wrote:
> On Thu, 2007-08-30 at 15:55 +0200, Helge Hafting wrote:
>   
>> If the swap device is full, then there is no need for random
>> seeks as the swap pages can be read in disk order.
>>     
>
> If the swap file is full, you probably have a machine dead into a swap
> storm.
Only if you have enough swap. :-)

Helge Hafting

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
