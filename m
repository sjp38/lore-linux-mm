Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id D43086B0037
	for <linux-mm@kvack.org>; Sun, 24 Nov 2013 10:14:21 -0500 (EST)
Received: by mail-la0-f43.google.com with SMTP id n7so2299200lam.30
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 07:14:21 -0800 (PST)
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
        by mx.google.com with ESMTPS id h4si7893047lam.71.2013.11.24.07.14.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 24 Nov 2013 07:14:20 -0800 (PST)
Received: by mail-la0-f51.google.com with SMTP id ec20so2205706lab.24
        for <linux-mm@kvack.org>; Sun, 24 Nov 2013 07:14:20 -0800 (PST)
Message-ID: <529217C7.6030304@cogentembedded.com>
Date: Sun, 24 Nov 2013 19:14:15 +0400
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: nobootmem: avoid type warning about alignment value
References: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1385249326-9089-1-git-send-email-santosh.shilimkar@ti.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-arm-kernel@lists.infradead.org

Hello.

On 24-11-2013 3:28, Santosh Shilimkar wrote:

> Building ARM with NO_BOOTMEM generates below warning. Using min_t

    Where is that below? :-)

> to find the correct alignment avoids the warning.

> Cc: Tejun Heo <tj@kernel.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Santosh Shilimkar <santosh.shilimkar@ti.com>

WBR, Sergei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
