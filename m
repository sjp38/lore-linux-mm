Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5306B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 10:55:13 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id o141so467844836itc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 07:55:13 -0800 (PST)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id b190si46907951iti.30.2017.01.04.07.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 07:55:12 -0800 (PST)
Date: Wed, 4 Jan 2017 09:55:08 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slub: do not merge cache if slub_debug contains a
 never-merge flag
In-Reply-To: <20170101124451.GA4740@lp-laptop-d>
Message-ID: <alpine.DEB.2.20.1701040954510.3281@east.gentwo.org>
References: <20161222235959.GC6871@lp-laptop-d> <alpine.DEB.2.20.1612231228340.21172@east.gentwo.org> <20161223190023.GA9644@lp-laptop-d> <alpine.DEB.2.20.1612241708280.9536@east.gentwo.org> <20170101124451.GA4740@lp-laptop-d>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Maistrenko <grygoriimkd@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>


Acked-by: Christoph Lameter <cl@linux.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
