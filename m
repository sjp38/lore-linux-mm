Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 721936B0253
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 17:54:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 75so216326465pgf.3
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:54:54 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id d20si1979013pfb.20.2017.01.23.14.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jan 2017 14:54:53 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id f144so10782094pfa.2
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 14:54:53 -0800 (PST)
Date: Mon, 23 Jan 2017 17:54:49 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH v2 02/10] slub: separate out sysfs_slab_release() from
 sysfs_slab_remove()
Message-ID: <20170123225449.GA29940@htj.duckdns.org>
References: <20170117235411.9408-1-tj@kernel.org>
 <20170117235411.9408-3-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117235411.9408-3-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

