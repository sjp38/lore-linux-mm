Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82D4A6B0038
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 19:25:51 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id f185so28120384itc.2
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 16:25:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7sor6875872iob.22.2017.12.30.16.25.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Dec 2017 16:25:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171230232643.12315-2-nefelim4ag@gmail.com>
References: <20171230232643.12315-1-nefelim4ag@gmail.com> <20171230232643.12315-2-nefelim4ag@gmail.com>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Sun, 31 Dec 2017 03:25:09 +0300
Message-ID: <CAGqmi76nFUmPbXw3nc7vzaYCiRtESs+pWgn1K_ADbWznaKE4Kw@mail.gmail.com>
Subject: Re: [PATCH V5 2/2] ksm: replace jhash2 with faster hash
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>

JFYI performance on more fast/modern CPU:
Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
[  172.651044] ksm: crc32c hash() 22633 MB/s
[  172.776060] ksm: xxhash hash() 10920 MB/s
[  172.776066] ksm: choice crc32c as hash function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
