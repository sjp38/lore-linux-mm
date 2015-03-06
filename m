Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id AF7EA6B006E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 11:01:36 -0500 (EST)
Received: by pabli10 with SMTP id li10so52612143pab.2
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 08:01:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id m1si15545882pdb.45.2015.03.06.08.01.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 08:01:33 -0800 (PST)
Date: Fri, 6 Mar 2015 19:01:18 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH 0/4] cleancache: remove limit on the number of cleancache
 enabled filesystems
Message-ID: <20150306160118.GD4762@esperanza>
References: <cover.1424628280.git.vdavydov@parallels.com>
 <20150223161222.GD30733@l.oracle.com>
 <20150224103406.GF16138@esperanza>
 <20150304212230.GB18253@l.oracle.com>
 <20150305164636.GB4762@esperanza>
 <20150306151426.GB4808@l.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150306151426.GB4808@l.oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 06, 2015 at 10:14:26AM -0500, Konrad Rzeszutek Wilk wrote:
> Would you be willing to fold in the description in the patch #4 and repost it?
> 
> Andrew - are you OK picking it up or would you prefer me as the maintainer
> to feed it to Linus? [either option is fine with me]

AFAICS Andrew has already picked it up with the description folded in
patch #4.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
