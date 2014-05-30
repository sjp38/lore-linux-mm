Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFDA6B0037
	for <linux-mm@kvack.org>; Fri, 30 May 2014 10:33:37 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id jw12so2194549veb.20
        for <linux-mm@kvack.org>; Fri, 30 May 2014 07:33:36 -0700 (PDT)
Received: from qmta15.emeryville.ca.mail.comcast.net (qmta15.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:228])
        by mx.google.com with ESMTP id dk3si3178670vcb.8.2014.05.30.07.33.35
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 07:33:36 -0700 (PDT)
Date: Fri, 30 May 2014 09:33:33 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH -mm 3/8] memcg: mark caches that belong to offline memcgs
 as dead
In-Reply-To: <2cb0d48c06a57586606deec0e368b4a3ecbc0b91.1401457502.git.vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1405300933190.11943@gentwo.org>
References: <cover.1401457502.git.vdavydov@parallels.com> <2cb0d48c06a57586606deec0e368b4a3ecbc0b91.1401457502.git.vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014, Vladimir Davydov wrote:

> This will be used by the next patches.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
