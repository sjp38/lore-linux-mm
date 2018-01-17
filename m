Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 86F4B6B026B
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:48:44 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e26so15534323pfi.15
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:48:44 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id b17si5375347pfl.222.2018.01.17.15.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 15:48:43 -0800 (PST)
Date: Wed, 17 Jan 2018 16:48:41 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH] linux-next: DOC: HWPOISON: Fix path to debugfs in
 hwpoison.txt
Message-ID: <20180117164841.12964dd9@lwn.net>
In-Reply-To: <20180111132837.9914-1-standby24x7@gmail.com>
References: <20180111132837.9914-1-standby24x7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, n-horiguchi@ah.jp.nec.com

On Thu, 11 Jan 2018 22:28:37 +0900
Masanari Iida <standby24x7@gmail.com> wrote:

> This patch fixes an incorrect path for debugfs in hwpoison.txt
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied, thanks.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
