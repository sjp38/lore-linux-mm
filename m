Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 069346B0044
	for <linux-mm@kvack.org>; Sat, 24 Nov 2012 10:06:30 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id s11so2295273qaa.14
        for <linux-mm@kvack.org>; Sat, 24 Nov 2012 07:06:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121122154107.GB11736@localhost>
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com>
 <20121120182500.GH1408@quack.suse.cz> <1353485020.53500.YahooMailNeo@web141104.mail.bf1.yahoo.com>
 <1353485630.17455.YahooMailNeo@web141106.mail.bf1.yahoo.com>
 <50AC9220.70202@gmail.com> <20121121090204.GA9064@localhost>
 <50ACA209.9000101@gmail.com> <1353491880.11679.YahooMailNeo@web141102.mail.bf1.yahoo.com>
 <50ACA634.5000007@gmail.com> <CAJOrxZBpefqtkXr+XTxEZ6qy-6SCwQJ11makD=Lg_M4itY5Ang@mail.gmail.com>
 <20121122154107.GB11736@localhost>
From: =?UTF-8?B?TWV0aW4gRMO2xZ9sw7w=?= <metindoslu@gmail.com>
Date: Sat, 24 Nov 2012 17:06:09 +0200
Message-ID: <CAJOrxZBp52a_7Rx6nxoSkMTTLHxA4pDnyfirLgN7BZXC8BxBzQ@mail.gmail.com>
Subject: Re: Problem in Page Cache Replacement
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>, Jan Kara <jack@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Nov 22, 2012 at 5:41 PM, Fengguang Wu <fengguang.wu@intel.com> wrot=
e:
> On Wed, Nov 21, 2012 at 12:07:22PM +0200, Metin D=C3=B6=C5=9Fl=C3=BC wrot=
e:
>> On Wed, Nov 21, 2012 at 12:00 PM, Jaegeuk Hanse <jaegeuk.hanse@gmail.com=
> wrote:
>> >
>> > On 11/21/2012 05:58 PM, metin d wrote:
>> >
>> > Hi Fengguang,
>> >
>> > I run tests and attached the results. The line below I guess shows the=
 data-1 page caches.
>> >
>> > 0x000000080000006c       6584051    25718  __RU_lA___________________P=
________    referenced,uptodate,lru,active,private
>> >
>> >
>> > I thinks this is just one state of page cache pages.
>>
>> But why these page caches are in this state as opposed to other page
>> caches. From the results I conclude that:
>>
>> data-1 pages are in state : referenced,uptodate,lru,active,private
>
> I wonder if it's this code that stops data-1 pages from being
> reclaimed:
>
> shrink_page_list():
>
>                 if (page_has_private(page)) {
>                         if (!try_to_release_page(page, sc->gfp_mask))
>                                 goto activate_locked;
>
> What's the filesystem used?

It was ext3.

>> data-2 pages are in state : referenced,uptodate,lru,mappedtodisk
>
> Thanks,
> Fengguang



--=20
Metin D=C3=B6=C5=9Fl=C3=BC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
