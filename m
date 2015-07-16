Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id B52722802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 20:09:22 -0400 (EDT)
Received: by ieik3 with SMTP id k3so45540237iei.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:09:22 -0700 (PDT)
Received: from mail-ie0-x22e.google.com (mail-ie0-x22e.google.com. [2607:f8b0:4001:c03::22e])
        by mx.google.com with ESMTPS id b18si202286igr.17.2015.07.15.17.09.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 17:09:22 -0700 (PDT)
Received: by ietj16 with SMTP id j16so45316228iet.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 17:09:22 -0700 (PDT)
Date: Wed, 15 Jul 2015 17:09:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 3/3] memtest: remove unused header files
In-Reply-To: <1436863249-1219-4-git-send-email-vladimir.murzin@arm.com>
Message-ID: <alpine.DEB.2.10.1507151709101.9230@chino.kir.corp.google.com>
References: <1436863249-1219-1-git-send-email-vladimir.murzin@arm.com> <1436863249-1219-4-git-send-email-vladimir.murzin@arm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, leon@leon.nu

On Tue, 14 Jul 2015, Vladimir Murzin wrote:

> memtest does not require these headers to be included.
> 
> Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
