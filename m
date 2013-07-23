Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id DB9AD6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 11:54:41 -0400 (EDT)
Received: from mail157-tx2 (localhost [127.0.0.1])	by
 mail157-tx2-R.bigfish.com (Postfix) with ESMTP id AA65818015D	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 15:54:40 +0000 (UTC)
Received: from TX2EHSMHS029.bigfish.com (unknown [10.9.14.227])	by
 mail157-tx2.bigfish.com (Postfix) with ESMTP id 00B6A200CB	for
 <linux-mm@kvack.org>; Tue, 23 Jul 2013 15:54:39 +0000 (UTC)
Received: from mail13-co1 (localhost [127.0.0.1])	by mail13-co1-R.bigfish.com
 (Postfix) with ESMTP id 1936CA401D7	for
 <linux-mm@kvack.org.FOPE.CONNECTOR.OVERRIDE>; Tue, 23 Jul 2013 15:54:20 +0000
 (UTC)
From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: base: memory: Export symbols for onlining
 memory blocks
Date: Tue, 23 Jul 2013 15:54:10 +0000
Message-ID: <3318be0a96cb4d05838d76dc9d088cc0@SN2PR03MB061.namprd03.prod.outlook.com>
References: <1374261785-1615-1-git-send-email-kys@microsoft.com>
 <20130722123716.GB24400@dhcp22.suse.cz>
 <e06fced3ca42408b980f8aa68f4a29f3@SN2PR03MB061.namprd03.prod.outlook.com>
 <51EEA11D.4030007@intel.com>
In-Reply-To: <51EEA11D.4030007@intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.cz>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>, "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>, "andi@firstfloor.org" <andi@firstfloor.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kamezawa.hiroyuki@gmail.com" <kamezawa.hiroyuki@gmail.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "yinghan@google.com" <yinghan@google.com>, "jasowang@redhat.com" <jasowang@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



> -----Original Message-----
> From: Dave Hansen [mailto:dave.hansen@intel.com]
> Sent: Tuesday, July 23, 2013 11:28 AM
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
> On 07/23/2013 07:52 AM, KY Srinivasan wrote:
> >  The current scheme of involving user
> > level code to close this loop obviously does not perform well under hig=
h
> memory pressure.
>=20
> Adding memory usually requires allocating some large, contiguous areas
> of memory for use as mem_map[] and other VM structures.  That's really
> hard to do under heavy memory pressure.  How are you accomplishing this?

I cannot avoid failures because of lack of memory. In this case I notify th=
e host of
the failure and also tag the failure as transient. Host retries the operati=
on after some
delay. There is no guarantee it will succeed though.

K. Y
>=20
>=20
>=20



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
