Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id D1F878E0004
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 12:04:38 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id c73so5230070itd.1
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 09:04:38 -0800 (PST)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50100.outbound.protection.outlook.com. [40.107.5.100])
        by mx.google.com with ESMTPS id z184-v6si2196132itd.117.2018.12.07.09.04.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Dec 2018 09:04:36 -0800 (PST)
From: Kirill Gorkunov <gorcunov@virtuozzo.com>
Subject: Re: [PATCH] mm: Remove useless check in pagecache_get_page()
Date: Fri, 7 Dec 2018 17:04:33 +0000
Message-ID: <20181207170430.GE11603@uranus.lan>
References: 
 <154419752044.18559.2452963074922917720.stgit@localhost.localdomain>
In-Reply-To: 
 <154419752044.18559.2452963074922917720.stgit@localhost.localdomain>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D62E4F1CFF946346BDC1B0E6304014A9@eurprd08.prod.outlook.com>
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Dec 07, 2018 at 06:46:24PM +0300, Kirill Tkhai wrote:
> page always is not NULL, so we may remove this useless check.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
Acked-by: Cyrill Gorcunov <gorcunov@gmail.com>
