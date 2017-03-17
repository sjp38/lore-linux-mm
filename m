Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9C51F6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 18:48:05 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id c85so84650924qkg.0
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 15:48:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i29si7496725qtf.101.2017.03.17.15.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 15:48:04 -0700 (PDT)
Date: Fri, 17 Mar 2017 18:48:02 -0400 (EDT)
From: Jerome Glisse <jglisse@redhat.com>
Message-ID: <503478426.8747709.1489790882925.JavaMail.zimbra@redhat.com>
In-Reply-To: <20170317040608.islf67cjbe25rjnx@wfg-t540p.sh.intel.com>
References: <201703170923.JOG5lvVO%fengguang.wu@intel.com> <20170316204135.da11fb9a50d22c264404a30e@linux-foundation.org> <20170317040608.islf67cjbe25rjnx@wfg-t540p.sh.intel.com>
Subject: Re: [kbuild-all] [mmotm:master 119/211] mm/migrate.c:2184:5: note:
 in expansion of macro 'MIGRATE_PFN_DEVICE'
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>

> Hi Andrew,
>=20
> On Thu, Mar 16, 2017 at 08:41:35PM -0700, Andrew Morton wrote:
> >On Fri, 17 Mar 2017 09:46:30 +0800 kbuild test robot
> ><fengguang.wu@intel.com> wrote:
> >
> >> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> >> head:   8276ddb3c638602509386f1a05f75326dbf5ce09
> >> commit: a6d9a210db7db40e98f7502608c6f1413c44b9b9 [119/211] mm/hmm/migr=
ate:
> >> support un-addressable ZONE_DEVICE page in migration
> >
> >heh, I think the HMM patchset just scored the world record number of
> >build errors.  Thanks for doing this.
> >
> >But why didn't we find out earlier than v18?  Don't you scoop patchsets
> >off the mailing list *before* someone merges them into an upstream
> >tree?
>=20
> Yes we test LKML patches, however not all patches can be successfully
> applied, so cannot be tested at all.

When patchset fails to apply can the poster get an email so he knows that
his patchset isn't gonna be build tested.

Regards,
J=C3=A9r=C3=B4me Glisse

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
