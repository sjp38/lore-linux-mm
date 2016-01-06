Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f45.google.com (mail-qg0-f45.google.com [209.85.192.45])
	by kanga.kvack.org (Postfix) with ESMTP id F2FB16B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 10:34:11 -0500 (EST)
Received: by mail-qg0-f45.google.com with SMTP id e32so214757618qgf.3
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 07:34:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x63si11184972qka.106.2016.01.06.07.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Jan 2016 07:34:11 -0800 (PST)
Subject: Re: [PATCH] mm: mempolicy: skip non-migratable VMAs when setting
 MPOL_MF_LAZY
References: <1452089927-22039-1-git-send-email-liangchen.linux@gmail.com>
From: Rik van Riel <riel@redhat.com>
Message-ID: <568D33F0.7080302@redhat.com>
Date: Wed, 6 Jan 2016 10:34:08 -0500
MIME-Version: 1.0
In-Reply-To: <1452089927-22039-1-git-send-email-liangchen.linux@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liang Chen <liangchen.linux@gmail.com>, linux-mm@kvack.org
Cc: mgorman@suse.de, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, linux-kernel@vger.kernel.org, Gavin Guo <gavin.guo@canonical.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

On 01/06/2016 09:18 AM, Liang Chen wrote:
> MPOL_MF_LAZY is not visible from userspace since 'commit
> a720094ded8c ("mm: mempolicy: Hide MPOL_NOOP and MPOL_MF_LAZY from
> userspace for now")' , but it should still skip non-migratable
> VMAs.

The changelog could use a better description of exactly
what the issue is, and why calling change_prot_numa
on a non-migratable VMA is causing problems.

> Signed-off-by: Liang Chen <liangchen.linux@gmail.com> 
> Signed-off-by: Gavin Guo <gavin.guo@canonical.com>

For the code itself:

Acked-by: Rik van Riel <riel@redhat.com>

Please resubmit with a better changelog.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWjTPwAAoJEM553pKExN6DCncIAKYtabnc7WjsI8/yzc0/qqYR
s92KJjztJ2RiaMhioa6xO1aGh9c00oszHvbZfFlYFJVWn/MsGB83eVQ0KymYLOdx
VyYP59Oe0oWvZagF4bvj7KEZVF35GFuUGOekLfbYihUw6VTgPE38cwAx9stIBTyf
CBm5XT0WdPLWaJrxYl5aJlbdQiJ7BKxQIBx7yyLV8tAgw0KVwEmPpgfftjAI1oIq
ItdrGDIqtOvb6vCc/5DJHT7+6b0ObwcpWWm4rE7QAc7OxyUUXbQydt/OKYXMhbUR
j6wcfHutHW2dcZko5iln7oN9DvBlYnXVSmSa4WJxgavtbL0abTaJGpJLE61pWQQ=
=sCoV
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
