Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 331F56B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 15:19:38 -0400 (EDT)
Message-ID: <4DB86BA4.8070401@draigBrady.com>
Date: Wed, 27 Apr 2011 20:16:52 +0100
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
References: <20110425180450.1ede0845@neptune.home>	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>	<20110425190032.7904c95d@neptune.home>	<BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>	<20110425203606.4e78246c@neptune.home>	<20110425191607.GL2468@linux.vnet.ibm.com>	<20110425231016.34b4293e@neptune.home>	<BANLkTin7wSGi1=E2c2u6Jb5TG_KUpYh=Dw@mail.gmail.com>	<20110425214933.GO2468@linux.vnet.ibm.com>	<20110426081904.0d2b1494@pluto.restena.lu>	<20110426112756.GF4308@linux.vnet.ibm.com>	<20110426183859.6ff6279b@neptune.home>	<20110426190918.01660ccf@neptune.home>	<BANLkTikjuqWP+PAsObJH4EAOyzgr2RbYNA@mail.gmail.com>	<alpine.LFD.2.02.1104262314110.3323@ionos>	<20110427081501.5ba28155@pluto.restena.lu> <20110427204139.1b0ea23b@neptune.home>
In-Reply-To: <20110427204139.1b0ea23b@neptune.home>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?Bruno_Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, paulmck@linux.vnet.ibm.com, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On 27/04/11 19:41, Bruno Premont wrote:
> On Wed, 27 April 2011 Bruno Premont wrote:
>> On Wed, 27 Apr 2011 00:28:37 +0200 (CEST) Thomas Gleixner wrote:
>>> On Tue, 26 Apr 2011, Linus Torvalds wrote:
>>>> On Tue, Apr 26, 2011 at 10:09 AM, Bruno Premont wrote:
>>>>>
>>>>> Just in case, /proc/$(pidof rcu_kthread)/status shows ~20k voluntary
>>>>> context switches and exactly one non-voluntary one.
>>>>>
>>>>> In addition when rcu_kthread has stopped doing its work
>>>>> `swapoff $(swapdevice)` seems to block forever (at least normal shutdown
>>>>> blocks on disabling swap device).
> 
> Apparently it's not swapoff but `umount -a -t tmpfs` that's getting
> stuck here. Manual swapoff worked.

Anything to do with this?
http://thread.gmane.org/gmane.linux.kernel.mm/60953/

cheers,
Padraig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
