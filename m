Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 691376B002D
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:49:58 -0500 (EST)
Received: by bke17 with SMTP id 17so1888328bke.14
        for <linux-mm@kvack.org>; Tue, 15 Nov 2011 10:49:53 -0800 (PST)
Date: Tue, 15 Nov 2011 20:49:35 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: INFO: possible recursive locking detected: get_partial_node()
 on 3.2-rc1
In-Reply-To: <20111115072251.GA10389@zhy>
Message-ID: <alpine.LFD.2.02.1111152049210.1888@tux.localdomain>
References: <20111109090556.GA5949@zhy> <201111102335.06046.kernelmail.jms@gmail.com> <1320980671.22361.252.camel@sli10-conroe> <alpine.DEB.2.00.1111110857330.3557@router.home> <1321248853.22361.280.camel@sli10-conroe> <20111115072251.GA10389@zhy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yong Zhang <yong.zhang0@gmail.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Christoph Lameter <cl@linux.com>, Julie Sullivan <kernelmail.jms@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 15 Nov 2011, Yong Zhang wrote:
>> Subject: slub: move discard_slab out of node lock
>>
>> Lockdep reports there is potential deadlock for slub node list_lock.
>> discard_slab() is called with the lock hold in unfreeze_partials(),
>> which could trigger a slab allocation, which could hold the lock again.
>>
>> discard_slab() doesn't need hold the lock actually, if the slab is
>> already removed from partial list.
>>
>> Reported-and-tested-by: Yong Zhang <yong.zhang0@gmail.com>
>> Reported-and-tested-by: Julie Sullivan <kernelmail.jms@gmail.com>
>> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>
> Tested-by: Yong Zhang <yong.zhang0@gmail.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
