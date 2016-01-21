Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id C60396B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 14:30:35 -0500 (EST)
Received: by mail-lb0-f170.google.com with SMTP id x4so29517319lbm.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 11:30:35 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id zv3si1240631lbb.206.2016.01.21.11.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 11:30:34 -0800 (PST)
Received: by mail-lb0-x229.google.com with SMTP id x4so29516977lbm.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 11:30:33 -0800 (PST)
Subject: Re: [PATCH] net: sock: remove dead cgroup methods from struct proto
References: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Message-ID: <56A131D7.4040102@cogentembedded.com>
Date: Thu, 21 Jan 2016 22:30:31 +0300
MIME-Version: 1.0
In-Reply-To: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello.

On 01/21/2016 10:01 PM, Johannes Weiner wrote:

> The cgroup methods are no longer used after baac50b ("net:

    12-digit ID is now enforced by scripts/checkpatch.pl.

> tcp_memcontrol: simplify linkage between socket and page counter").
> The hunk to delete them was included in the original patch but must
> have gotten lost during conflict resolution on the way upstream.
>
> Fixes: baac50b ("net: tcp_memcontrol: simplify linkage between socket and page counter")

    Here as well.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
[...]

MBR, Sergei


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
