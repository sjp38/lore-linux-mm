Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2669F6B004F
	for <linux-mm@kvack.org>; Thu, 20 Aug 2009 06:32:47 -0400 (EDT)
Message-ID: <4A8D26BF.8090806@redhat.com>
Date: Thu, 20 Aug 2009 18:34:39 +0800
From: Amerigo Wang <amwang@redhat.com>
MIME-Version: 1.0
Subject: Re: [Patch] proc: drop write permission on 'timer_list' and	'slabinfo'
References: <20090817094822.GA17838@elte.hu> <1250502847.5038.16.camel@penberg-laptop> <alpine.DEB.1.10.0908171228300.16267@gentwo.org> <4A8986BB.80409@cs.helsinki.fi> <alpine.DEB.1.10.0908171240370.16267@gentwo.org> <4A8A0B0D.6080400@redhat.com> <4A8A0B14.8040700@cn.fujitsu.com> <4A8A1B2E.20505@redhat.com> <20090818120032.GA22152@localhost> <4A8B652E.40905@redhat.com> <20090819023737.GA17710@localhost> <4A8BD67F.8020007@redhat.com> <4A8C48AB.1030700@cs.helsinki.fi>
In-Reply-To: <4A8C48AB.1030700@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Li Zefan <lizf@cn.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vegard Nossum <vegard.nossum@gmail.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Amerigo Wang wrote:
>> Pekka, could you please also take the patch attached below? It is 
>> just a trivial coding style fix. And it is based on the my previous 
>> patch.
>
> The last hunk was already in slab.git because I fixed your patch up by 
> hand. I applied the rest but can you please send proper patches in the 
> future? That is, no attachments and a "git am" friendly subject line. 
> Thanks!

Nice. Thanks!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
