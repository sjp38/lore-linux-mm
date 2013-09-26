Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3CA746B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 11:29:43 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y13so1298883pdi.5
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 08:29:42 -0700 (PDT)
Message-ID: <524452E3.6050200@linux.intel.com>
Date: Thu, 26 Sep 2013 08:29:39 -0700
From: Arjan van de Ven <arjan@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com> <52437128.7030402@linux.vnet.ibm.com> <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org> <52442F6F.5020703@linux.vnet.ibm.com>
In-Reply-To: <52442F6F.5020703@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, dave@sr71.net, hannes@cmpxchg.org, tony.luck@intel.com, matthew.garrett@nebula.com, riel@redhat.com, srinivas.pandruvada@linux.intel.com, willy@linux.intel.com, kamezawa.hiroyu@jp.fujitsu.com, lenb@kernel.org, rjw@sisk.pl, gargankita@gmail.com, paulmck@linux.vnet.ibm.com, svaidy@linux.vnet.ibm.com, andi@firstfloor.org, isimatu.yasuaki@jp.fujitsu.com, santosh.shilimkar@ti.com, kosaki.motohiro@gmail.com, linux-pm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, maxime.coquelin@stericsson.com, loic.pallardy@stericsson.com, amit.kachhap@linaro.org, thomas.abraham@linaro.org

On 9/26/2013 5:58 AM, Srivatsa S. Bhat wrote:
> Let me explain the challenge I am facing. A prototype powerpc platform that
> I work with has the capability to transition memory banks to content-preserving
> low-power states at a per-socket granularity. What that means is that we can
> get memory power savings*without*  needing to go to full-system-idle, unlike
> Intel platforms such as Sandybridge.

btw this is not a correct statement
even Sandybridge can put memory in low power states (just not self refresh) even if the system is not idle
(depending on bios settings to enable this)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
