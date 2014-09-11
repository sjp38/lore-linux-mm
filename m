Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id A87876B0074
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 05:27:28 -0400 (EDT)
Received: by mail-qc0-f179.google.com with SMTP id o8so4611892qcw.38
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 02:27:28 -0700 (PDT)
Received: from na01-bn1-obe.outbound.protection.outlook.com (mail-bn1bbn0101.outbound.protection.outlook.com. [157.56.111.101])
        by mx.google.com with ESMTPS id q7si348132qga.5.2014.09.11.02.27.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 11 Sep 2014 02:27:28 -0700 (PDT)
From: "Li.Xiubo@freescale.com" <Li.Xiubo@freescale.com>
Subject: RE: [PATCH] mm/compaction: Fix warning of 'flags' may be used
 uninitialized
Date: Thu, 11 Sep 2014 09:27:24 +0000
Message-ID: <584917bf2134400882e23b62469975d4@BY2PR0301MB0613.namprd03.prod.outlook.com>
References: <1410329540-40708-1-git-send-email-Li.Xiubo@freescale.com>
 <alpine.DEB.2.02.1409101149500.27173@chino.kir.corp.google.com>
 <20140911080455.GA22047@dhcp22.suse.cz>
In-Reply-To: <20140911080455.GA22047@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "vbabka@suse.cz" <vbabka@suse.cz>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

> > Arnd Bergmann already sent a patch for this to use uninitialized_var()
> > privately but it didn't get cc'd to any mailing list, sorry.
>=20
> Besides that setting flags to 0 is certainly a misleading way to fix
> this issue. uninitialized_var is a correct way because the warning is a
> false possitive. compact_unlock_should_abort will not touch the flags if
> locked is false and this is true only after a lock has been taken and
> flags set. (this should be preferably in the patch description).
>=20

Yes, right.

This should be added to the commit comment with the patch.

Thanks,

BRs
Xiubo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
