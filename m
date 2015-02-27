Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EC9326B0032
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 01:23:05 -0500 (EST)
Received: by paceu11 with SMTP id eu11so20223152pac.7
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 22:23:05 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id jf9si4262132pbd.36.2015.02.26.22.23.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Feb 2015 22:23:05 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t1R6N1Tr009337
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 27 Feb 2015 15:23:02 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch] mm, mempolicy: migrate_to_node should only migrate to
 node
Date: Fri, 27 Feb 2015 06:13:58 +0000
Message-ID: <20150227061358.GA7469@hori1.linux.bs1.fc.nec.co.jp>
References: <alpine.DEB.2.10.1502241511540.8003@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1502241511540.8003@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <931A2F01C617E848B30D3349A514E9A4@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 24, 2015 at 03:18:06PM -0800, David Rientjes wrote:
> migrate_to_node() is intended to migrate a page from one source node to a=
=20
> target node.
>=20
> Today, migrate_to_node() could end up migrating to any node, not only the=
=20
> target node.  This is because the page migration allocator,=20
> new_node_page() does not pass __GFP_THISNODE to alloc_pages_exact_node().=
 =20
> This causes the target node to be preferred but allows fallback to any=20
> other node in order of affinity.
>=20
> Prevent this by allocating with __GFP_THISNODE.  If memory is not=20
> available, -ENOMEM will be returned as appropriate.
>=20
> Signed-off-by: David Rientjes <rientjes@google.com>

Make sense to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
