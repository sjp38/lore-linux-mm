Message-ID: <473A7A0B.5030300@arca.com.cn>
Date: Wed, 14 Nov 2007 12:31:07 +0800
From: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>
MIME-Version: 1.0
Subject: Re: about page migration on UMA
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>	 <20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>	 <alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>	 <20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>	 <alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>	 <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>	 <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>	 <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com> <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
In-Reply-To: <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Christoph Lameter <clameter@sgi.com>, climeter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Jared Hulbert a??e??:
> On 10/18/07, Christoph Lameter <clameter@sgi.com> wrote:
>   
>> On Wed, 17 Oct 2007, Jacky(GuangXiang  Lee) wrote:
>>
>>     
>>> seems page migration is used mostly for NUMA platform to improve
>>> performance.
>>> But in a UMA architecture, Is it possible to use page migration to move
>>> pages ?
>>>       
>> Yes. Just one up with a usage for it. The page migration mechanism itself
>> is not NUMA dependent.
>>     
>
> For extreme low power systems it would be possible to shut down banks
> in SDRAM chips that were not full thereby saving power.  That would
> require some defraging and migration to empty them prior to powering
> down those banks.
>
>   
what is the way to shut down banks in SDRAM chips?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
