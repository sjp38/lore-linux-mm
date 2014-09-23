Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFC96B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 17:09:33 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id l13so5400892iga.0
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 14:09:33 -0700 (PDT)
Received: from stargate.chelsio.com (99-65-72-228.uvs.sntcca.sbcglobal.net. [99.65.72.228])
        by mx.google.com with ESMTPS id c3si3508554igx.10.2014.09.23.14.09.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 23 Sep 2014 14:09:32 -0700 (PDT)
From: Anish Bhatt <anish@chelsio.com>
Subject: RE: mmotm 2014-09-22-16-57 uploaded
Date: Tue, 23 Sep 2014 21:08:54 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D88F1F9D@nice.asicdesigners.com>
References: <5420b8b0.9HdYLyyuTikszzH8%akpm@linux-foundation.org>
 <20140923190222.GA4662@roeck-us.net>
 <20140923130128.79f5931ac03dbb31f53be805@linux-foundation.org>
 <20140923203832.GA1112@roeck-us.net>
In-Reply-To: <20140923203832.GA1112@roeck-us.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "sfr@canb.auug.org.au" <sfr@canb.auug.org.au>, "mhocko@suse.cz" <mhocko@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, David
 Miller <davem@davemloft.net>, Fabio Estevam <fabio.estevam@freescale.com>, Randy Dunlap <rdunlap@infradead.org>

> > cc'ing Anish Bhatt.
> >
> He knows about it, as do David Miller and Randy Dunlap (who proposed it)
> [1].
> There just doesn't seem to be an agreement on how to fix the problem.
> A simple revert doesn't work anymore since there are multiple follow-up
> patches, and if I understand correctly David is opposed to a revert anywa=
y.

Dave is working on  a patch based on Randy's last solution :
http://www.spinics.net/lists/netdev/msg297593.html

Not sure of the current status.
-Anish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
