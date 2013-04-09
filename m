Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id CA5036B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 22:05:29 -0400 (EDT)
Message-ID: <516377CF.2080004@cn.fujitsu.com>
Date: Tue, 09 Apr 2013 10:07:11 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: vmemmap: arm64: add vmemmap_verify check for
 hot-add node case
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com> <1365415000-10389-3-git-send-email-linfeng@cn.fujitsu.com> <20130408105556.GB17476@mudshark.cambridge.arm.com>
In-Reply-To: <20130408105556.GB17476@mudshark.cambridge.arm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "cl@linux.com" <cl@linux.com>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@redhat.com" <mingo@redhat.com>, "hpa@zytor.com" <hpa@zytor.com>, "yinghai@kernel.org" <yinghai@kernel.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "arnd@arndb.de" <arnd@arndb.de>, "tony@atomide.com" <tony@atomide.com>, "ben@decadent.org.uk" <ben@decadent.org.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>

Hi will,

On 04/08/2013 06:55 PM, Will Deacon wrote:
> Given that we don't have NUMA support or memory-hotplug on arm64 yet, I'm
> not sure that this change makes much sense at the moment. early_pfn_to_nid
> will always return 0 and we only ever have one node.
> 
> To be honest, I'm not sure what that vmemmap_verify check is trying to
> achieve anyway. ia64 does some funky node affinity initialisation early on
> but, for the rest of us, it looks like we always just check the distance
> from node 0.

Sorry for my noise to arm people.

Yes, not everyone cares about vmemmap_verify(), as you described it's not
necessary to arm64 at all. 

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
