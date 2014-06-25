Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f45.google.com (mail-qa0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0422C6B0031
	for <linux-mm@kvack.org>; Wed, 25 Jun 2014 12:19:06 -0400 (EDT)
Received: by mail-qa0-f45.google.com with SMTP id v10so1729418qac.32
        for <linux-mm@kvack.org>; Wed, 25 Jun 2014 09:19:06 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id l10si5271729qad.51.2014.06.25.09.19.06
        for <linux-mm@kvack.org>;
        Wed, 25 Jun 2014 09:19:06 -0700 (PDT)
Date: Wed, 25 Jun 2014 11:19:02 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH] slab: document why cache can have no per cpu array on
 kfree
In-Reply-To: <1403707177-3740-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.11.1406251118440.26523@gentwo.org>
References: <20140624073840.GC4836@js1304-P5Q-DELUXE> <1403707177-3740-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, rientjes@google.com, penberg@kernel.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
