Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 38D806B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 14:28:19 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id h10-v6so6769685ybm.12
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:28:19 -0700 (PDT)
Received: from mail.stoffel.org (mail.stoffel.org. [104.236.43.127])
        by mx.google.com with ESMTPS id x12si3347097uac.249.2018.04.30.11.28.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 11:28:17 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <23271.24580.695738.853532@quad.stoffel.home>
Date: Mon, 30 Apr 2018 14:27:16 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [dm-devel] [PATCH v5] fault-injection: introduce kvmalloc
 fallback options
In-Reply-To: <alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org>
	<20180424162906.GM17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424170349.GQ17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com>
	<20180424173836.GR17484@dhcp22.suse.cz>
	<alpine.LRH.2.02.1804251556060.30569@file01.intranet.prod.int.rdu2.redhat.com>
	<1114eda5-9b1f-4db8-2090-556b4a37c532@infradead.org>
	<alpine.LRH.2.02.1804251656300.9428@file01.intranet.prod.int.rdu2.redhat.com>
	<alpine.DEB.2.21.1804251417470.166306@chino.kir.corp.google.com>
	<alpine.LRH.2.02.1804251720090.9428@file01.intranet.prod.int.rdu2.redhat.com>
	<1524694663.4100.21.camel@HansenPartnership.com>
	<alpine.LRH.2.02.1804251857070.31135@file01.intranet.prod.int.rdu2.redhat.com>
	<1524697697.4100.23.camel@HansenPartnership.com>
	<23266.8532.619051.784274@quad.stoffel.home>
	<alpine.LRH.2.02.1804261726540.13401@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: John Stoffel <john@stoffel.org>, Andrew@stoffel.org, eric.dumazet@gmail.com, mst@redhat.com, edumazet@google.com, netdev@vger.kernel.org, jasowang@redhat.com, Randy Dunlap <rdunlap@infradead.org>, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, Hocko <mhocko@kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, Michal@stoffel.org, dm-devel@redhat.com, David Miller <davem@davemloft.net>, David Rientjes <rientjes@google.com>, Morton <akpm@linux-foundation.org>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

>>>>> "Mikulas" == Mikulas Patocka <mpatocka@redhat.com> writes:

Mikulas> On Thu, 26 Apr 2018, John Stoffel wrote:

>> >>>>> "James" == James Bottomley <James.Bottomley@HansenPartnership.com> writes:
>> 
James> I may be an atypical developer but I'd rather have a root canal
James> than browse through menuconfig options.  The way to get people
James> to learn about new debugging options is to blog about it (or
James> write an lwn.net article) which google will find the next time
James> I ask it how I debug XXX.  Google (probably as a service to
James> humanity) rarely turns up Kconfig options in response to a
James> query.
>> 
>> I agree with James here.  Looking at the SLAB vs SLUB Kconfig entries
>> tells me *nothing* about why I should pick one or the other, as an
>> example.
>> 
>> John

Mikulas> I see your point - and I think the misunderstanding is this.

Thanks.

Mikulas> This patch is not really helping people to debug existing crashes. It is 
Mikulas> not like "you get a crash" - "you google for some keywords" - "you get a 
Mikulas> page that suggests to turn this option on" - "you turn it on and solve the 
Mikulas> crash".

Mikulas> What this patch really does is that - it makes the kernel deliberately 
Mikulas> crash in a situation when the code violates the specification, but it 
Mikulas> would not crash otherwise or it would crash very rarely. It helps to 
Mikulas> detect specification violations.

Mikulas> If the kernel developer (or tester) doesn't use this option, his buggy 
Mikulas> code won't crash - and if it won't crash, he won't fix the bug or report 
Mikulas> it. How is the user or developer supposed to learn about this option, if 
Mikulas> he gets no crash at all?

So why do we make this a KConfig option at all?  Just turn it on and
let it rip.  Now I also think that Linus has the right idea to not
just sprinkle BUG_ONs into the code, just dump and oops and keep going
if you can.  If it's a filesystem or a device, turn it read only so
that people notice right away.
