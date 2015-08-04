Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7577D6B0253
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 23:08:05 -0400 (EDT)
Received: by padck2 with SMTP id ck2so104643995pad.0
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 20:08:05 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id x2si30165011pdi.17.2015.08.03.20.08.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 03 Aug 2015 20:08:04 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t74380xW024508
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 4 Aug 2015 12:08:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/3] vm hugetlb selftest cleanup
Date: Tue, 4 Aug 2015 03:04:41 +0000
Message-ID: <20150804030432.GA13839@hori1.linux.bs1.fc.nec.co.jp>
References: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1438304393-30413-1-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <EAE1668293101442BC47DD9BB848DFEF@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "joern@purestorage.com" <joern@purestorage.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>

On Thu, Jul 30, 2015 at 05:59:50PM -0700, Mike Kravetz wrote:
> As a followup to discussions of hugetlbfs fallocate, this provides
> cleanup the vm hugetlb selftests.  Remove hugetlbfstest as it tests
> functionality not present in the kernel.  Emphasize that libhugetlbfs
> test suite should be used for hugetlb regression testing.
>=20
> Mike Kravetz (3):
>   Reverted "selftests: add hugetlbfstest"
>   selftests:vm: Point to libhugetlbfs for regression testing
>   Documentation: update libhugetlbfs location and use for testing

It seems that patch 1 conflicts with commit bd67d5c15cc1 ("Test compaction
of mlocked memory"), but the resolution is trivial, so for the series ...

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks!=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
