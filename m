Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1666B006E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 09:57:23 -0500 (EST)
Date: Fri, 11 Nov 2011 08:57:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: INFO: possible recursive locking detected: get_partial_node()
 on 3.2-rc1
In-Reply-To: <20111111044202.GA21013@zhy>
Message-ID: <alpine.DEB.2.00.1111110853211.3557@router.home>
References: <20111109090556.GA5949@zhy> <201111102335.06046.kernelmail.jms@gmail.com> <1320980671.22361.252.camel@sli10-conroe> <20111111044202.GA21013@zhy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yong Zhang <yong.zhang0@gmail.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Julie Sullivan <kernelmail.jms@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Looks like a false positive.

put_cpu_partial() can be called with a parameter to indicate if draining
of the per cpu partial list should be allowed ("drain"). Draining requires
taking the list lock. "drain" is set to 0 when called from
get_partial_node() (where we are already holding the list lock) so no
deadlock should be possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
