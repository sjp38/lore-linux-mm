Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id F3CA46B00B3
	for <linux-mm@kvack.org>; Sat, 15 Nov 2014 12:11:04 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id r20so2020234wiv.5
        for <linux-mm@kvack.org>; Sat, 15 Nov 2014 09:11:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gd8si8517898wib.41.2014.11.15.09.11.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Nov 2014 09:11:04 -0800 (PST)
Message-ID: <5467891B.2010100@redhat.com>
Date: Sat, 15 Nov 2014 12:10:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: do not overwrite reserved pages counter at show_mem()
References: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
In-Reply-To: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 11/14/2014 01:34 PM, Rafael Aquini wrote:
> Minor fixlet to perform the reserved pages counter aggregation for
> each node, at show_mem()
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUZ4kbAAoJEM553pKExN6DtgUH/32t89g4pK7Tqgj6jSs2nzGq
AHLma8dL12/JABVPBBqHxwSXCRDF6klCuQPx9v1RMiaksGf4TNNjDnEwDJ65Out4
I0ckZoc2bXRZi9i4IGZEuaAoBjN2CUL2tbgxqQLjO17nLlS+NDJuhtqQzFTE2EyO
uO3wtLBPEtQa7HaBNsElzdauU/pKgT/67s0PtExCTdQAIjLDEqjSI8pT0ltPx0xk
UG9l1ffFy5UhScugoSJDOfbWoZ3YjBZeWwZZ4so4u503TyNOPbucMi8lYyMDMxKd
67SyN2hWb6eKm1d4MXZZwibrbx/YGg/Ngc8kqoC1IDS7Xsl1jPgD3K5IeDMIFFs=
=yglK
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
