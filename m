Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 0144A6B0037
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 07:15:06 -0400 (EDT)
Received: from mail196-co9 (localhost [127.0.0.1])	by
 mail196-co9-R.bigfish.com (Postfix) with ESMTP id 8C2A1500195	for
 <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:15:05 +0000 (UTC)
Received: from CO9EHSMHS032.bigfish.com (unknown [10.236.132.244])	by
 mail196-co9.bigfish.com (Postfix) with ESMTP id 290F5C801C6	for
 <linux-mm@kvack.org>; Thu, 25 Jul 2013 11:15:03 +0000 (UTC)
Received: from mail210-co9 (localhost [127.0.0.1])	by
 mail210-co9-R.bigfish.com (Postfix) with ESMTP id B8232940252	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Thu, 25 Jul 2013 11:14:25 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Thu, 25 Jul 2013 11:14:18 +0000
Message-ID: <4f440c8d96f34711a3f06fb18702a297@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
 <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA11D.4030007@intel.com>
 <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA89F.9070309@intel.com>
 <9f351a549e76483d9148f87535567ea0@SN2PR03MB061.namprd03.prod.outlook.com>
 <51F00415.8070104@sr71.net>
 <d1f80c05986b439cbeef12bcd595b264@BLUPR03MB050.namprd03.prod.outlook.com>
 <51F040E8.1030507@intel.com> <20130725075705.GD12818@dhcp22.suse.cz>
In-Reply-To: <20130725075705.GD12818@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave@sr71.net>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@suse.cz]
> Sent: Thursday, July 25, 2013 3:57 AM
> To: Dave Hansen
> Cc: KY Srinivasan; Dave Hansen; gregkh@linuxfoundation.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; andi@firstfloor.org; akpm@linux-foundation.org; linux-
> mm@kvack.org; kamezawa.hiroyuki@gmail.com; hannes@cmpxchg.org;
> yinghan@google.com; jasowang@redhat.com; kay@vrfy.org
> Subject: Re: [PATCH 1/1] Drivers: base: memory: Export symbols for onlini=
ng
> memory blocks
>=20
> On Wed 24-07-13 14:02:32, Dave Hansen wrote:
> > On 07/24/2013 12:45 PM, KY Srinivasan wrote:
> > > All I am saying is that I see two classes of failures: (a) Our
> > > inability to allocate memory to manage the memory that is being hot a=
dded
> > > and (b) Our inability to bring the hot added memory online within a
> reasonable
> > > amount of time. I am not sure the cause for (b) and I was just specul=
ating that
> > > this could be memory related. What is interesting is that I have seen=
 failure
> related
> > > to our inability to online the memory after having succeeded in hot a=
dding the
> > > memory.
> >
> > I think we should hold off on this patch and other like it until we've
> > been sufficiently able to explain how (b) happens.
>=20
> Agreed.

As promised, I have sent out the patches for (a) an implementation of an in=
-kernel API
for onlining  and a consumer for this API. While I don't know the exact rea=
son why the
user mode code is delayed (under some low memory conditions), what is the h=
arm in having
a mechanism to online memory that has been hot added without involving user=
 space code.
Based on Michal's feedback, the onlininig API hides all of the internal det=
ails and presents a
generic interface.

Regards,

K. Y



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
