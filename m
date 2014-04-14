Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 242E36B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 16:21:09 -0400 (EDT)
Received: by mail-qg0-f46.google.com with SMTP id 63so8710161qgz.33
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 13:21:07 -0700 (PDT)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id y105si7269426qgd.90.2014.04.14.13.21.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 13:21:07 -0700 (PDT)
Received: by mail-qa0-f46.google.com with SMTP id i13so8405040qae.19
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 13:21:06 -0700 (PDT)
Date: Mon, 14 Apr 2014 16:21:03 -0400
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] percpu: make pcpu_alloc_chunk() use pcpu_mem_free() instead
 of kfree()
Message-ID: <20140414202103.GE16835@htj.dyndns.org>
References: <1397454460-19694-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397454460-19694-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Applied to percpu/for-3.15-fixes with slightly updated commit message.

Thanks.

------- 8< -------
