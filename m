Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F17996B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 15:00:14 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1714386pad.37
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:00:14 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srivatsa.bhat@linux.vnet.ibm.com>;
	Fri, 27 Sep 2013 00:30:09 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 29E62394005A
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 00:29:52 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QJ2PRS31588596
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 00:32:25 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8QJ069B018180
	for <linux-mm@kvack.org>; Fri, 27 Sep 2013 00:30:07 +0530
Message-ID: <52448340.7060802@linux.vnet.ibm.com>
Date: Fri, 27 Sep 2013 00:26:00 +0530
From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <20130925234734.GK18242@two.firstfloor.org> <52438AA9.3020809@linux.intel.com> <20130925182129.a7db6a0fd2c7cc3b43fda92d@linux-foundation.org> <20130926015016.GM18242@two.firstfloor.org> <20130925195953.826a9f7d.akpm@linux-foundation.org> <524439D5.8020306@linux.vnet.ibm.com> <52445993.7050608@linux.intel.com> <52446841.2030301@linux.vnet.ibm.com> <524477AC.9090400@linux.intel.com> <52447DED.5080205@linux.vnet.ibm.com> <3908561D78D1C84285E8C5FCA982C28F31D1BA12@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31D1BA12@ORSMSX106.amr.corp.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Arjan van de Ven <arjan@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, "mgorman@suse.de" <mgorman@suse.de>, "dave@sr71.net" <dave@sr71.net>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "matthew.garrett@nebula.com" <matthew.garrett@nebula.com>, "riel@redhat.com" <riel@redhat.com>, "srinivas.pandruvada@linux.intel.com" <srinivas.pandruvada@linux.intel.com>, "willy@linux.intel.com" <willy@linux.intel.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "lenb@kernel.org" <lenb@kernel.org>, "rjw@sisk.pl" <rjw@sisk.pl>, "gargankita@gmail.com" <gargankita@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "svaidy@linux.vnet.ibm.com" <svaidy@linux.vnet.ibm.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "santosh.shilimkar@ti.com" <santosh.shilimkar@ti.com>, "kosaki.motohiro@gmail.com" <kosaki.motohiro@gmail.com>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "maxime.coquelin@stericsson.com" <maxime.coquelin@stericsson.com>, "loic.pallardy@stericsson.com" <loic.pallardy@stericsson.com>, "thomas.abraham@linaro.org" <thomas.abraham@linaro.org>, "amit.kachhap@linaro.org" <amit.kachhap@linaro.org>

On 09/27/2013 12:20 AM, Luck, Tony wrote:
>> And that's it! No other case for page movement. And with this conservative
>> approach itself, I'm getting great consolidation ratios!
>> I am also thinking of adding more smartness in the code to be very choosy in
>> doing the movement, and do it only in cases where it is almost guaranteed to
>> be beneficial. For example, I can make the kmempowerd kthread more "lazy"
>> while moving/reclaiming stuff; I can bias the page movements such that "cold"
>> pages are left around (since they are not expected to be referenced much
>> anyway) and only the (few) hot pages are moved... etc.
> 
> Can (or should) this migrator coordinate with khugepaged - I'd hate to see them
> battling over where to move pages ... or undermining each other (your daemon
> frees up a 512MB area ... and khugepaged immediately grabs a couple of 2MB
> pages from it to upgrade some process with a scattershot of 4K pages).
> 

That's a very good point! I need to look into it to see how such sub-optimal
behavior can be avoided (perhaps by making khugepaged region-aware)... Hmmm..
Thanks for bringing it up!

Regards,
Srivatsa S. Bhat

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
