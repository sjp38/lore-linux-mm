Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 40B416B0037
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 13:22:34 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so1618120pad.28
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 10:22:33 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [Results] [RFC PATCH v4 00/40] mm: Memory Power Management
Date: Thu, 26 Sep 2013 17:22:30 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F31D1B6BE@ORSMSX106.amr.corp.intel.com>
References: <20130925231250.26184.31438.stgit@srivatsabhat.in.ibm.com>
 <52437128.7030402@linux.vnet.ibm.com>
 <20130925164057.6bbaf23bdc5057c42b2ab010@linux-foundation.org>
 <52442F6F.5020703@linux.vnet.ibm.com>
In-Reply-To: <52442F6F.5020703@linux.vnet.ibm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "mgorman@suse.de" <mgorman@suse.de>, "dave@sr71.net" <dave@sr71.net>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "matthew.garrett@nebula.com" <matthew.garrett@nebula.com>, "riel@redhat.com" <riel@redhat.com>, "arjan@linux.intel.com" <arjan@linux.intel.com>, "srinivas.pandruvada@linux.intel.com" <srinivas.pandruvada@linux.intel.com>, "willy@linux.intel.com" <willy@linux.intel.com>, "kamezawa.hiroyu@jp.fujitsu.com" <kamezawa.hiroyu@jp.fujitsu.com>, "lenb@kernel.org" <lenb@kernel.org>, "rjw@sisk.pl" <rjw@sisk.pl>, "gargankita@gmail.com" <gargankita@gmail.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "svaidy@linux.vnet.ibm.com" <svaidy@linux.vnet.ibm.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "santosh.shilimkar@ti.com" <santosh.shilimkar@ti.com>, "kosaki.motohiro@gmail.com" <kosaki.motohiro@gmail.com>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "maxime.coquelin@stericsson.com" <maxime.coquelin@stericsson.com>, "loic.pallardy@stericsson.com" <loic.pallardy@stericsson.com>, "amit.kachhap@linaro.org" <amit.kachhap@linaro.org>, "thomas.abraham@linaro.org" <thomas.abraham@linaro.org>

> As Andi mentioned, the wakeup latency is not expected to be noticeable. A=
nd
> these power-savings logic is turned on in the hardware by default. So its=
 not
> as if this patchset is going to _introduce_ that latency. This patchset o=
nly
> tries to make the Linux MM _cooperate_ with the (already existing) hardwa=
re
> power-savings logic and thereby get much better memory power-savings bene=
fits
> out of it.

You will still get the blame :-)   By grouping active memory areas along h/=
w power
boundaries you enable the power saving modes to kick in (where before they =
didn't
because of scattered access to all areas).  This seems very similar to sche=
duler changes
that allow processors to go idle long enough to enter deep C-states ... ups=
etting
users who notice the exit latency.

The interleave problem mentioned elsewhere in this thread is possibly a big=
 problem.
High core counts mean that memory bandwidth can be the bottleneck for sever=
al
workloads.  Dropping, or reducing, the degree of interleaving will seriousl=
y impact
bandwidth (unless your applications are spread out "just right").

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
