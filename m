Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 141288E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 05:47:18 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id p21so35310429itb.8
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 02:47:18 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y2si30972828iol.35.2019.01.03.02.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 02:47:17 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm: Introduce page_size()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190102130932.GH6310@bombadil.infradead.org>
Date: Thu, 3 Jan 2019 03:47:02 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <DFC451D4-9262-4538-A14E-4B05932C2D6C@oracle.com>
References: <20181231134223.20765-1-willy@infradead.org>
 <87y385awg6.fsf@linux.ibm.com> <20190101063031.GD6310@bombadil.infradead.org>
 <87lg447knf.fsf@linux.ibm.com> <20190102031414.GG6310@bombadil.infradead.org>
 <0952D432-F520-4830-A1DE-479DFAD283E7@oracle.com>
 <20190102130932.GH6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org



> On Jan 2, 2019, at 6:09 AM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> I'm not sure I agree with that.  It's going to depend on exactly what =
this
> code is doing; I can definitely see there being places in the VM where =
we
> care about how this page is currently mapped, but I think those places
> are probably using the wrong interface (get_user_pages()) and should
> really be using an interface which doesn't exist yet (get_user_sg()).

Fair enough; I also agree the VM_BUG_ON for tail pages might be a good =
safety
measure, at least to see if anyone ends up calling page_size() that way =
at present.
