Message-ID: <3EB8E4CC.8010409@aitel.hist.no>
Date: Wed, 07 May 2003 12:49:48 +0200
From: Helge Hafting <helgehaf@aitel.hist.no>
MIME-Version: 1.0
Subject: Re: 2.5.69-mm2 Kernel panic, possibly network related
References: <20030506232326.7e7237ac.akpm@digeo.com>	 <3EB8DBA0.7020305@aitel.hist.no> <1052304024.9817.3.camel@rth.ninka.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David S. Miller wrote:
> On Wed, 2003-05-07 at 03:10, Helge Hafting wrote:
> 
>>2.5.69-mm1 is fine, 2.5.69-mm2 panics after a while even under very
>>light load.
> 
> 
> Do you have AF_UNIX built modular?

No, I compile everything into a monolithic kernel.
I don't even enable module support.

Helge Hafting




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
