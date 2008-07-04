Message-ID: <486E2E9B.20200@garzik.org>
Date: Fri, 04 Jul 2008 10:07:23 -0400
From: Jeff Garzik <jeff@garzik.org>
MIME-Version: 1.0
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
References: <1215093175.10393.567.camel@pmac.infradead.org>	 <20080703173040.GB30506@mit.edu>	 <1215111362.10393.651.camel@pmac.infradead.org>	 <20080703.162120.206258339.davem@davemloft.net>	 <486D6DDB.4010205@infradead.org>  <87ej6armez.fsf@basil.nowhere.org>	 <1215177044.10393.743.camel@pmac.infradead.org>	 <486E2260.5050503@garzik.org>	 <1215178035.10393.763.camel@pmac.infradead.org>	 <486E2818.1060003@garzik.org> <1215179161.10393.773.camel@pmac.infradead.org>
In-Reply-To: <1215179161.10393.773.camel@pmac.infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

David Woodhouse wrote:
> On Fri, 2008-07-04 at 09:39 -0400, Jeff Garzik wrote:
>> You have been told repeatedly that cp(1) and scp(1) are commonly used
>> to transport the module David and I care about -- tg3.  It's been a
>> single file module since birth, and people take advantage of that
>> fact.
> 
> And you can _continue_ to do that. You'd need to install the firmware
> just once, and that's all. It's a non-issue, and it isn't _worth_ the
> added complexity of building the firmware into the module.

We can stop there.  Real-world examples are apparently non-issues not 
worth your time.

	Jeff



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
