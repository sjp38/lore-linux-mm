Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 9ED076B0034
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:50:29 -0400 (EDT)
Received: from mail137-co1 (localhost [127.0.0.1])	by
 mail137-co1-R.bigfish.com (Postfix) with ESMTP id 460BEDC0170	for
 <linux-mm@kvack.org>; Thu, 25 Jul 2013 15:50:27 +0000 (UTC)
Received: from CO1EHSMHS022.bigfish.com (unknown [10.243.78.249])	by
 mail137-co1.bigfish.com (Postfix) with ESMTP id 9579860004C	for
 <linux-mm@kvack.org>; Thu, 25 Jul 2013 15:50:23 +0000 (UTC)
Received: from mail214-ch1 (localhost [127.0.0.1])	by
 mail214-ch1-R.bigfish.com (Postfix) with ESMTP id C1F81140235	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Thu, 25 Jul 2013 15:50:00 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Thu, 25 Jul 2013 15:49:00 +0000
Message-ID: <828d748273884d6f9c24b658964f97c3@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
 <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA11D.4030007@intel.com>
 <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA89F.9070309@intel.com>
 <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51F00415.8070104@sr71.net>
 <d1f80c05986b439cbeef12bcd595b264@BLUPR03MB050.namprd03.prod.outlook.com>
 <51F040E8.1030507@intel <51F13E51.7040808@sr71.net>
In-Reply-To: <51F13E51.7040808@sr71.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Dave Hansen [mailto:dave@sr71.net]
> Sent: Thursday, July 25, 2013 11:04 AM
> To: KY Srinivasan
> Cc: Michal Hocko; gregkh@linuxfoundation.org; linux-kernel@vger.kernel.or=
g;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> andi@firstfloor.org; akpm@linux-foundation.org; linux-mm@kvack.org;
> kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org; yinghan@google.com;
> jasowang@redhat.com; kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On 07/25/2013 04:14 AM, KY Srinivasan wrote:
> > As promised, I have sent out the patches for (a) an implementation of a=
n in-
> kernel API
> > for onlining  and a consumer for this API. While I don't know the exact=
 reason
> why the
> > user mode code is delayed (under some low memory conditions), what is t=
he
> harm in having
> > a mechanism to online memory that has been hot added without involving =
user
> space code.
>=20
> KY, your potential problem, not being able to online more memory because
> of a shortage of memory, is a serious one.

All I can say is that the online is not happening within the allowed time (=
5 seconds in
the current code).
>=20
> However, this potential issue exists in long-standing code, and
> potentially affects all users of memory hotplug.  The problem has not
> been described in sufficient detail for the rest of the developers to
> tell if you are facing a new problem, or whether *any* proposed solution
> will help the problem you face.
>=20
> Your propsed solution changes the semantics of existing user/kernel
> interfaces, duplicates existing functionality, and adds code complexity
> to the kernel.

How so? All I am doing is to use the existing infrastructure to online
memory. The only change I have made is to export an API that allows
onlining without involving any user space code. I don't see how  this
adds complexity to the kernel. This would be an useful extension as can
be seen from its usage in the Hyper-V balloon driver.

In my particular use case, I need to wait for the memory to be onlined befo=
re
I can proceed to hot add the next chunk. This synchronization can be comple=
tely
avoided if we can avoid the involvement of user level code. I would submit =
to you that
this is a valid use case that we ought to be able to support.

Regards,

K. Y



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
