Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 67D166B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 04:58:25 -0500 (EST)
Message-ID: <4ED35B3E.7040105@redhat.com>
Date: Mon, 28 Nov 2011 09:58:22 +0000
From: Christine Caulfield <ccaulfie@redhat.com>
MIME-Version: 1.0
Subject: Re: [BUG] 3.2-rc2: BUG kmalloc-8: Redzone overwritten
References: <1321870529.2552.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321870915.2552.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1321873110.2710.13.camel@menhir> <20111126.155028.1986754382924402334.davem@davemloft.net>
In-Reply-To: <20111126.155028.1986754382924402334.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: swhiteho@redhat.com, eric.dumazet@gmail.com, levinsasha928@gmail.com, mpm@selenic.com, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org

On 26/11/11 20:50, David Miller wrote:
> From: Steven Whitehouse<swhiteho@redhat.com>
> Date: Mon, 21 Nov 2011 10:58:30 +0000
>
>> I have to say that I've been wondering lately whether it has got to the
>> point where it is no longer useful. Has anybody actually tested it
>> lately against "real" DEC implementations?
>
> I doubt it :-)
>

DECnet is in use against real DEC implementations - I have checked it 
quite recently against a VAX running OpenVMS. How many people are 
actually using it for real work is a different question though.

It's also true that it's not really supported by anyone as I orphaned it 
some time ago and nobody else seems to care enough to take it over. So 
if it's becoming a burden on people doing real kernel work then I don't 
think many tears will be wept for its removal.

Chrissie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
