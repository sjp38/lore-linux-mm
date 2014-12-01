Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9156B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 17:46:21 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id b13so15527460wgh.32
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 14:46:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id ek2si47320193wid.102.2014.12.01.14.46.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 14:46:20 -0800 (PST)
Message-ID: <547CEFAA.7020103@redhat.com>
Date: Mon, 01 Dec 2014 17:46:02 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/4] mm: Refactor do_wp_page - rewrite the unlock flow
References: <1417467491-20071-1-git-send-email-raindel@mellanox.com> <1417467491-20071-3-git-send-email-raindel@mellanox.com>
In-Reply-To: <1417467491-20071-3-git-send-email-raindel@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>, linux-mm@kvack.org
Cc: kirill.shutemov@linux.intel.com, mgorman@suse.de, ak@linux.intel.com, matthew.r.wilcox@intel.com, dave.hansen@linux.intel.com, n-horiguchi@ah.jp.nec.com, akpm@linux-foundation.org, torvalds@linux-foundation.org, haggaie@mellanox.com, aarcange@redhat.com, pfeiner@google.com, hannes@cmpxchg.org, sagig@mellanox.com, walken@google.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/01/2014 03:58 PM, Shachar Raindel wrote:
> When do_wp_page is ending, in several cases it needs to unlock the 
> pages and ptls it was accessing.
> 
> Currently, this logic was "called" by using a goto jump. This
> makes following the control flow of the function harder.
> Readability was further hampered by the unlock case containing
> large amount of logic needed only in one of the 3 cases.
> 
> Using goto for cleanup is generally allowed. However, moving the 
> trivial unlocking flows to the relevant call sites allow deeper 
> refactoring in the next patch.
> 
> Signed-off-by: Shachar Raindel <raindel@mellanox.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfO+qAAoJEM553pKExN6D4zMIAJCXpbwTi/aPFnes03x5/VVY
NRxhhWUessVxK4gM0jwG8JU/MKisrZ1bNbL997yd8Vv8H6UScoLvJNjfUYYpvsy1
WdmBZJzUmq5QH3pemNnEooz50cPWxVzcHhtMXFf+3UQ0NG/5MqIaUGNN+tjs7+rU
ynW4oCB1jHbIRCLlPhvydW5lc1Z5+7h9I2wkHfN+A9p7JF1wExH6jc8Qc5mJcPy2
xmNJViTep7C43JC8KYXqOnS6FtW10vPBC/hMs0/6DTasaox5ztD+qoEtotIpne1U
OaDWyZkUxLyyYl1BRaujxQzEwaS/Z3cHH30WOuKiJhwnWOX8PfjykQ/tBzKIAe0=
=d25J
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
