Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id E2E3C6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 10:53:25 -0400 (EDT)
Received: from mail140-va3 (localhost [127.0.0.1])	by
 mail140-va3-R.bigfish.com (Postfix) with ESMTP id 93628E01C3	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 14:53:24 +0000 (UTC)
Received: from VA3EHSMHS032.bigfish.com (unknown [10.7.14.239])	by
 mail140-va3.bigfish.com (Postfix) with ESMTP id 9C84416004D	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 14:53:23 +0000 (UTC)
Received: from mail137-db9 (localhost [127.0.0.1])	by
 mail137-db9-R.bigfish.com (Postfix) with ESMTP id A6E4A2E035D	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 23 Jul 2013 14:52:43 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Tue, 23 Jul 2013 14:52:36 +0000
Message-ID: <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
In-Reply-To: <20130722123716.GB24400@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Monday, July 22, 2013 8:37 AM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com;
> jasowang@redhat.com; kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On Fri 19-07-13 12:23:05, K. Y. Srinivasan wrote:
> > The current machinery for hot-adding memory requires having udev
> > rules to bring the memory segments online. Export the necessary functio=
nality
> > to to bring the memory segment online without involving user space code=
.
>=20
> Why? Who is going to use it and for what purpose?
> If you need to do it from the kernel cannot you use usermod helper
> thread?
>=20
> Besides that this is far from being complete. memory_block_change_state
> seems to depend on device_hotplug_lock and find_memory_block is
> currently called with mem_sysfs_mutex held. None of them is exported
> AFAICS.

You are right; not all of the required symbols are exported (yet). Let me a=
nswer your
other questions first:

The Hyper-V balloon driver can use this functionality. I have prototyped th=
e in-kernel
"onlining" of hot added memory without requiring any help from user level c=
ode that
performs significantly better than having user level code involved in the h=
ot add process.
With this change, I am able to successfully hot-add and online the hot-adde=
d memory
even under extreme memory pressure which is what you would want given that =
we are
hot-adding memory to alleviate memory pressure. The current scheme of invol=
ving user
level code to close this loop obviously does not perform well under high me=
mory pressure.


I can, if you prefer export all of the necessary functionality in one patch=
.


Regards,

K. Y


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
