Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 082D028001E
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 06:14:20 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id z60so2548318qgd.36
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:14:20 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id g5si6135562qay.78.2014.10.31.03.14.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 31 Oct 2014 03:14:19 -0700 (PDT)
Received: by mail-qc0-f169.google.com with SMTP id i17so5674353qcy.28
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 03:14:19 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 31 Oct 2014 18:14:19 +0800
Message-ID: <CAFNq8R7xYA2GTpWE-5rHr5c-xX0ZONKHX6wSbra2MDo1M2DSHQ@mail.gmail.com>
Subject: [PATCH] Frontswap: fix the condition in BUG_ON
From: Li Haifeng <omycle@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: open list <linux-kernel@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

