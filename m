Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 9718B6B0062
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 01:43:45 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9788611dak.14
        for <linux-mm@kvack.org>; Mon, 18 Jun 2012 22:43:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120619041154.GA28651@shangw>
References: <1339623535.3321.4.camel@lappy>
	<20120614032005.GC3766@dhcp-172-17-108-109.mtv.corp.google.com>
	<1339667440.3321.7.camel@lappy>
	<20120618223203.GE32733@google.com>
	<1340059850.3416.3.camel@lappy>
	<20120619041154.GA28651@shangw>
Date: Mon, 18 Jun 2012 22:43:44 -0700
Message-ID: <CAE9FiQVitg0ODjph96LnPD6pnWSSN8QkFngEwbUX9-nT-sdy+g@mail.gmail.com>
Subject: Re: Early boot panic on machine with lots of memory
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Jun 18, 2012 at 9:11 PM, Gavin Shan <shangw@linux.vnet.ibm.com> wro=
te:
> :
> [ =A0 =A00.000000] =A0 =A0memblock_free: [0x0000102febc080-0x0000102febf0=
80] memblock_free_reserved_regions+0x37/0x39
>
> Here, [0x0000102febc080-0x0000102febf080] was released to available memor=
y block
> by function free_low_memory_core_early(). I'm not sure the release memblo=
ck might
> be taken by bootmem, but I think it's worthy to have a try of removing fo=
llowing
> 2 lines: memblock_free_reserved_regions() and memblock_reserve_reserved_r=
egions()

if it was taken, should have print out about that.

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
