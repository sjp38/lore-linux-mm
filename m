Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A1B8A8E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 18:02:23 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 68so8435613pfr.6
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 15:02:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11sor15205336pfj.7.2018.12.09.15.02.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 15:02:22 -0800 (PST)
Date: Sun, 9 Dec 2018 15:02:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] docs/mm-api: link slab_common.c to "The Slab Cache"
 section
In-Reply-To: <1544130781-13443-3-git-send-email-rppt@linux.ibm.com>
Message-ID: <alpine.DEB.2.21.1812091502070.206717@chino.kir.corp.google.com>
References: <1544130781-13443-1-git-send-email-rppt@linux.ibm.com> <1544130781-13443-3-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 6 Dec 2018, Mike Rapoport wrote:

> Several functions in mm/slab_common.c have kernel-doc comments, it makes
> perfect sense to link them to the MM API reference.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>
