Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id E19AB6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 05:43:20 -0500 (EST)
Received: by mail-vb0-f52.google.com with SMTP id fa15so4780684vbb.25
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 02:43:19 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 20 Feb 2013 18:43:19 +0800
Message-ID: <CANZA+xgRWQe2fm8Gok4SxRXEeRU5CztijG4HKNeTDFQfSgHPPw@mail.gmail.com>
Subject: What does the PG_swapbacked of page flags actually mean?
From: common An <xx.kernel@gmail.com>
Content-Type: multipart/alternative; boundary=20cf307f377a61b71c04d625a021
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

--20cf307f377a61b71c04d625a021
Content-Type: text/plain; charset=ISO-8859-1

PG_swapbacked is a bit for page->flags.

In kernel code, its comment is "page is backed by RAM/swap". But I couldn't
understand it.
1. Does the RAM mean DRAM? How page is backed by RAM?
2. When the page is page-out to swap file, the bit PG_swapbacked will be
set to demonstrate this page is backed by swap. Is it right?
3. In general, when will call SetPageSwapBacked() to set the bit?

Could anybody kindly explain for me?

Thanks very much.

--20cf307f377a61b71c04d625a021
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

PG_swapbacked is a bit for page-&gt;flags.<div><br></div><div>In kernel cod=
e, its comment is &quot;page is backed by RAM/swap&quot;.=A0But I couldn&#3=
9;t understand it.=A0</div><div>1. Does the RAM mean DRAM? How page is back=
ed by RAM?</div>


<div>2. When the page is page-out to swap file, the bit PG_swapbacked will =
be set to demonstrate this page is backed by swap. Is it right?</div><div>3=
. In general, when will call SetPageSwapBacked() to set the bit?</div>

<div>
<br></div><div>Could anybody kindly explain for me?=A0</div><div><br></div>=
<div>Thanks very much.</div>

--20cf307f377a61b71c04d625a021--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
